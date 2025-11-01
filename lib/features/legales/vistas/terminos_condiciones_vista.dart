import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';

/// Vista de Términos y Condiciones
class TerminosCondicionesVista extends StatelessWidget {
  const TerminosCondicionesVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
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
              'Términos y Condiciones de Uso',
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
              titulo: '1. Aceptación de los Términos',
              contenido:
                  'Al acceder y utilizar la aplicación Resiliencia UCSS, usted acepta estar sujeto a estos Términos y Condiciones. Si no está de acuerdo con alguna parte de estos términos, no debe utilizar esta aplicación.',
            ),

            _buildSeccion(
              titulo: '2. Uso de la Aplicación',
              contenido:
                  'Esta aplicación está diseñada exclusivamente para estudiantes de la Universidad Católica Sedes Sapientiae (UCSS) - Filial Nueva Cajamarca. El uso de esta aplicación es para fines educativos y de evaluación psicológica preventiva.',
            ),

            _buildSeccion(
              titulo: '3. Registro de Usuario',
              contenido:
                  'Para utilizar esta aplicación, debe:\n\n'
                  '• Ser estudiante activo de la UCSS\n'
                  '• Proporcionar información veraz y actualizada\n'
                  '• Usar su correo institucional (@ucss.pe)\n'
                  '• Mantener la confidencialidad de su contraseña\n'
                  '• Notificar cualquier uso no autorizado de su cuenta',
            ),

            _buildSeccion(
              titulo: '4. Evaluaciones Psicológicas',
              contenido:
                  'Los tests de evaluación proporcionados en esta aplicación:\n\n'
                  '• Son de carácter preventivo y orientativo\n'
                  '• NO reemplazan una evaluación profesional completa\n'
                  '• Utilizan el Inventario de Ansiedad de Beck (BAI)\n'
                  '• Deben realizarse de forma honesta para obtener resultados precisos\n'
                  '• Se realizarán cada 30 días como mínimo',
            ),

            _buildSeccion(
              titulo: '5. Confidencialidad y Privacidad',
              contenido:
                  'Sus resultados de evaluación:\n\n'
                  '• Están encriptados y protegidos\n'
                  '• Solo son accesibles por usted y el personal autorizado del servicio de psicología\n'
                  '• Pueden ser compartidos con psicólogos de la universidad para su seguimiento\n'
                  '• No serán compartidos con terceros sin su consentimiento',
            ),

            _buildSeccion(
              titulo: '6. Derivación al Servicio de Psicología',
              contenido:
                  'En caso de que los resultados indiquen niveles de ansiedad moderados o graves:\n\n'
                  '• Se generará automáticamente una derivación al servicio de psicología\n'
                  '• Un profesional se pondrá en contacto con usted dentro de las 48 horas\n'
                  '• Es importante que asista a las citas programadas\n'
                  '• La derivación es para su bienestar y apoyo',
            ),

            _buildSeccion(
              titulo: '7. Responsabilidades del Usuario',
              contenido:
                  'Usted se compromete a:\n\n'
                  '• Responder los tests con honestidad\n'
                  '• Seguir las recomendaciones proporcionadas\n'
                  '• Asistir a las citas con el psicólogo si es derivado\n'
                  '• No compartir su cuenta con terceros\n'
                  '• Reportar cualquier problema técnico',
            ),

            _buildSeccion(
              titulo: '8. Limitaciones de Responsabilidad',
              contenido:
                  'La UCSS y los desarrolladores de esta aplicación:\n\n'
                  '• No se responsabilizan por el uso inadecuado de la aplicación\n'
                  '• No garantizan resultados específicos de las intervenciones\n'
                  '• No sustituyen el criterio profesional de psicólogos licenciados\n'
                  '• Pueden modificar o discontinuar el servicio sin previo aviso',
            ),

            _buildSeccion(
              titulo: '9. Propiedad Intelectual',
              contenido:
                  'Todo el contenido de esta aplicación, incluyendo textos, diseños, gráficos y software, es propiedad de la UCSS y está protegido por las leyes de propiedad intelectual.',
            ),

            _buildSeccion(
              titulo: '10. Modificaciones',
              contenido:
                  'Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios serán efectivos inmediatamente después de su publicación en la aplicación. Su uso continuado de la aplicación constituye su aceptación de los términos modificados.',
            ),

            _buildSeccion(
              titulo: '11. Contacto',
              contenido:
                  'Para preguntas sobre estos Términos y Condiciones, puede contactar al servicio de psicología de la UCSS - Filial Nueva Cajamarca.',
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresApp.primario.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColoresApp.primario.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ColoresApp.primario,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Al crear una cuenta, usted acepta estos Términos y Condiciones.',
                      style: TextStyle(
                        fontSize: 13,
                        color: ColoresApp.primario,
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
