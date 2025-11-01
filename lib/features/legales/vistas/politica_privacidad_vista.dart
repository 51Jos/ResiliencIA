import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';

/// Vista de Política de Privacidad
class PoliticaPrivacidadVista extends StatelessWidget {
  const PoliticaPrivacidadVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Política de Privacidad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoOscuro,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(
                fontSize: 14,
                color: ColoresApp.textoMedio,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            _buildSeccion(
              titulo: '1. Introducción',
              contenido:
                  'La Universidad Católica Sedes Sapientiae (UCSS) - Filial Nueva Cajamarca se compromete a proteger su privacidad. Esta Política de Privacidad explica cómo recopilamos, usamos, compartimos y protegemos su información personal cuando utiliza la aplicación Resiliencia UCSS.',
            ),

            _buildSeccion(
              titulo: '2. Información que Recopilamos',
              contenido:
                  'Recopilamos los siguientes tipos de información:\n\n'
                  '**Información de Registro:**\n'
                  '• Nombres y apellidos\n'
                  '• Correo electrónico institucional (@ucss.pe)\n'
                  '• Facultad y carrera\n'
                  '• Filial (Nueva Cajamarca)\n\n'
                  '**Información de Evaluaciones:**\n'
                  '• Respuestas a los tests de ansiedad (encriptadas)\n'
                  '• Puntajes obtenidos\n'
                  '• Niveles de ansiedad identificados\n'
                  '• Fechas de realización de tests\n'
                  '• Historial de evaluaciones\n\n'
                  '**Información Técnica:**\n'
                  '• Registros de inicio de sesión\n'
                  '• Datos de uso de la aplicación\n'
                  '• Información del dispositivo',
            ),

            _buildSeccion(
              titulo: '3. Cómo Usamos su Información',
              contenido:
                  'Utilizamos su información para:\n\n'
                  '• Proporcionar servicios de evaluación psicológica\n'
                  '• Generar recomendaciones personalizadas\n'
                  '• Identificar estudiantes que requieren apoyo psicológico\n'
                  '• Derivar casos al servicio de psicología cuando sea necesario\n'
                  '• Realizar seguimiento del progreso de los estudiantes\n'
                  '• Generar estadísticas agregadas y anónimas\n'
                  '• Mejorar nuestros servicios\n'
                  '• Cumplir con obligaciones legales',
            ),

            _buildSeccion(
              titulo: '4. Encriptación y Seguridad',
              contenido:
                  'Implementamos medidas de seguridad robustas:\n\n'
                  '**Encriptación de Datos:**\n'
                  '• Sus respuestas a los tests están encriptadas con algoritmos AES-256\n'
                  '• Solo usted y el personal autorizado pueden acceder a sus datos desencriptados\n'
                  '• Cada usuario tiene una clave de encriptación única\n\n'
                  '**Almacenamiento Seguro:**\n'
                  '• Utilizamos Firebase de Google para almacenamiento seguro\n'
                  '• Conexiones protegidas con HTTPS\n'
                  '• Autenticación de dos factores disponible\n'
                  '• Respaldos automáticos y redundancia de datos',
            ),

            _buildSeccion(
              titulo: '5. Compartir Información',
              contenido:
                  'Su información puede ser compartida con:\n\n'
                  '**Personal Autorizado de la UCSS:**\n'
                  '• Psicólogos del servicio de psicología\n'
                  '• Personal administrativo autorizado\n'
                  '• Solo con fines de atención y seguimiento\n\n'
                  '**NO compartimos su información con:**\n'
                  '• Terceros no autorizados\n'
                  '• Empresas de marketing\n'
                  '• Otros estudiantes\n'
                  '• Redes sociales',
            ),

            _buildSeccion(
              titulo: '6. Sus Derechos',
              contenido:
                  'Usted tiene derecho a:\n\n'
                  '• **Acceso:** Ver toda su información personal\n'
                  '• **Corrección:** Solicitar la corrección de datos inexactos\n'
                  '• **Eliminación:** Solicitar la eliminación de su cuenta y datos\n'
                  '• **Portabilidad:** Obtener una copia de sus datos\n'
                  '• **Objeción:** Oponerse a ciertos usos de su información\n'
                  '• **Retiro de consentimiento:** Retirar su consentimiento en cualquier momento',
            ),

            _buildSeccion(
              titulo: '7. Retención de Datos',
              contenido:
                  'Conservamos su información:\n\n'
                  '• Mientras sea estudiante activo de la UCSS\n'
                  '• Hasta 5 años después de su graduación o retiro (para fines de seguimiento)\n'
                  '• Datos estadísticos anónimos: indefinidamente\n'
                  '• Puede solicitar la eliminación anticipada de sus datos',
            ),

            _buildSeccion(
              titulo: '8. Cookies y Tecnologías Similares',
              contenido:
                  'Esta aplicación puede utilizar:\n\n'
                  '• Cookies de sesión para mantenerlo conectado\n'
                  '• Almacenamiento local para mejorar el rendimiento\n'
                  '• Analytics para entender el uso de la aplicación',
            ),

            _buildSeccion(
              titulo: '9. Menores de Edad',
              contenido:
                  'Si es menor de 18 años, necesita el consentimiento de sus padres o tutores para usar esta aplicación. Al registrarse, confirma que tiene el consentimiento necesario.',
            ),

            _buildSeccion(
              titulo: '10. Cambios a esta Política',
              contenido:
                  'Podemos actualizar esta Política de Privacidad periódicamente. Le notificaremos sobre cambios significativos mediante:\n\n'
                  '• Notificación en la aplicación\n'
                  '• Correo electrónico a su dirección registrada\n'
                  '• Actualización de la fecha de "Última actualización"',
            ),

            _buildSeccion(
              titulo: '11. Contacto y Consultas',
              contenido:
                  'Para ejercer sus derechos o hacer consultas sobre privacidad:\n\n'
                  '• Contacte al servicio de psicología UCSS - Nueva Cajamarca\n'
                  '• Envíe un correo a través de su cuenta institucional\n'
                  '• Visite las oficinas administrativas de la universidad',
            ),

            _buildSeccion(
              titulo: '12. Cumplimiento Legal',
              contenido:
                  'Esta política cumple con:\n\n'
                  '• Ley de Protección de Datos Personales del Perú (Ley N° 29733)\n'
                  '• Reglamento de la Ley de Protección de Datos Personales\n'
                  '• Directivas de la Autoridad Nacional de Protección de Datos',
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresApp.exito.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColoresApp.exito.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: ColoresApp.exito,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sus datos están protegidos con encriptación de nivel empresarial.',
                      style: TextStyle(
                        fontSize: 13,
                        color: ColoresApp.exito,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required String contenido,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoOscuro,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contenido,
            style: const TextStyle(
              fontSize: 14,
              color: ColoresApp.textoMedio,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
