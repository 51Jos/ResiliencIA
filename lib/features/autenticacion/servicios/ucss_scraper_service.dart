import 'dart:io';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as html_parser;
// ignore: depend_on_referenced_packages
import 'package:html/dom.dart';
import 'package:http/io_client.dart';

class UCSSScraperService {
  final String baseUrl = 'https://intranet.ucss.edu.pe';
  final String loginUrl = 'https://intranet.ucss.edu.pe/ucss-intranet/login/ingresar.aspx';

  late final http.Client _client;

  UCSSScraperService() {
    // Crear un cliente HTTP que acepte certificados SSL no verificados
    // NOTA: Solo usar en desarrollo/testing. En producción debería verificarse el certificado
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    _client = IOClient(httpClient);
  }
  final Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'es-ES,es;q=0.9,en;q=0.8',
  };

  final Map<String, String> _cookies = {};

  /// Extrae ViewState y otros campos ocultos de ASP.NET
  Map<String, String> _extractViewState(Document document) {
    final viewStateData = <String, String>{};

    final fields = [
      '__VIEWSTATE',
      '__VIEWSTATEGENERATOR',
      '__EVENTVALIDATION',
      '__EVENTTARGET',
      '__EVENTARGUMENT'
    ];

    for (final field in fields) {
      final element = document.querySelector('input[name="$field"]');
      if (element != null) {
        final value = element.attributes['value'];
        if (value != null && value.isNotEmpty) {
          viewStateData[field] = value;
        }
      }
    }

    return viewStateData;
  }

  /// Extrae todos los campos del formulario
  Map<String, String> _extractFormFields(Document document) {
    final formFields = <String, String>{};

    final form = document.querySelector('form');
    if (form == null) {
      throw Exception('No se encontró el formulario de login');
    }

    final inputs = form.querySelectorAll('input');
    for (final input in inputs) {
      final name = input.attributes['name'];
      final value = input.attributes['value'] ?? '';
      if (name != null && name.isNotEmpty) {
        formFields[name] = value;
      }
    }

    return formFields;
  }

  /// Extrae y almacena cookies de la respuesta
  void _extractCookies(http.Response response) {
    final cookiesHeader = response.headers['set-cookie'];
    if (cookiesHeader != null) {
      final cookies = cookiesHeader.split(',');
      for (final cookie in cookies) {
        final parts = cookie.split(';')[0].split('=');
        if (parts.length == 2) {
          _cookies[parts[0].trim()] = parts[1].trim();
        }
      }
    }
  }

  /// Convierte las cookies almacenadas en un string para el header
  String _getCookieHeader() {
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  /// Realiza el login en el sistema
  Future<LoginResult> login(String username, String password) async {
    try {

      // Paso 1: Obtener la página de login
      final initialResponse = await _client.get(
        Uri.parse(loginUrl),
        headers: _headers,
      );

      if (initialResponse.statusCode != 200) {
        return LoginResult(
          success: false,
          message: 'Error al cargar la página de login: ${initialResponse.statusCode}',
        );
      }

      _extractCookies(initialResponse);

      // Parsear HTML
      final document = html_parser.parse(initialResponse.body);

      // Extraer ViewState y campos del formulario
      final viewStateData = _extractViewState(document);
      final formFields = _extractFormFields(document);


      // Paso 2: Preparar datos de login
      final loginData = <String, String>{
        ...formFields,
        ...viewStateData,
      };

      // Agregar credenciales a los campos de UCSS
      loginData['txtUsuarioMail'] = username;
      loginData['txtPwd'] = password;

      // Agregar botón de submit
      loginData['btnIngresar'] = 'Ingresar';

      // Paso 3: Enviar credenciales

      final loginHeaders = {
        ..._headers,
        'Cookie': _getCookieHeader(),
        'Content-Type': 'application/x-www-form-urlencoded',
        'Referer': loginUrl,
      };

      final loginResponse = await _client.post(
        Uri.parse(loginUrl),
        headers: loginHeaders,
        body: loginData,
      );

      _extractCookies(loginResponse);

      // Verificar si el login fue exitoso (status 302 = redirección exitosa)
      if (loginResponse.statusCode == 302) {
        return LoginResult(
          success: true,
          message: 'Login exitoso',
        );
      }

      // Si no es 302, el login falló
      return LoginResult(
        success: false,
        message: 'Credenciales incorrectas',
      );

    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Captura los datos de la página de inicio
  Future<HomePageData> getHomePageData() async {
    try {
      // Obtener datos del carnet virtual
      final carnetUrl = '$baseUrl/ucss-intranet/academico/carnet-virtual.aspx';

      final homeResponse = await _client.get(
        Uri.parse(carnetUrl),
        headers: {
          ..._headers,
          'Cookie': _getCookieHeader(),
        },
      );

      if (homeResponse.statusCode != 200) {
        return HomePageData(
          url: carnetUrl,
          title: 'Error',
          htmlCompleto: '',
          error: 'No se pudo acceder al carnet virtual',
        );
      }

      final document = html_parser.parse(homeResponse.body);

      return HomePageData(
        url: carnetUrl,
        title: document.querySelector('title')?.text ?? 'Carnet Virtual UCSS',
        estudianteInfo: _extractEstudianteInfo(document),
        htmlCompleto: homeResponse.body,
      );

    } catch (e) {
      return HomePageData(
        url: '',
        title: 'Error',
        htmlCompleto: '',
        error: e.toString(),
      );
    }
  }

  Map<String, String> _extractEstudianteInfo(Document document) {
    final info = <String, String>{};

    // Extraer Codigo Universitario (buscar números de 8-10 dígitos)
    final lines = document.querySelectorAll('[class*="cssCarneBodyDatosLinea"]');
    for (final line in lines) {
      final text = line.text.trim();

      if (text.contains(RegExp(r'\d{8,10}')) && !info.containsKey('dni')) {
        final match = RegExp(r'(\d{8,10})').firstMatch(text);
        if (match != null) {
          info['codigoUniversitario'] = match.group(1)!;
        }
      }
    }

    // Extraer apellidos y nombres
    final apellidosElement = document.querySelector('#cphBody_spApellidos');
    if (apellidosElement != null) {
      info['apellidos'] = apellidosElement.text.trim();
    }

    final nombresElement = document.querySelector('#cphBody_spNombres');
    if (nombresElement != null) {
      info['nombres'] = nombresElement.text.trim();
    }

    // Extraer facultad y carrera
    final facultadElement = document.querySelector('#cphBody_spFacultad');
    if (facultadElement != null) {
      info['facultad'] = facultadElement.text.trim();
    }    

    return info;
  }

  void dispose() {
    _client.close();
  }
}

class LoginResult {
  final bool success;
  final String message;
  final String? redirectUrl;

  LoginResult({
    required this.success,
    required this.message,
    this.redirectUrl,
  });
}

class HomePageData {
  final String url;
  final String title;
  final Map<String, String>? estudianteInfo;
  final String htmlCompleto;
  final String? error;

  HomePageData({
    required this.url,
    required this.title,
    this.estudianteInfo,
    required this.htmlCompleto,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'estudianteInfo': estudianteInfo,
      'error': error,
    };
  }
}
