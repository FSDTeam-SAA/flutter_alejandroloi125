import 'package:alejandroloi/core/language/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreenView extends StatelessWidget {
  const PrivacyPolicyScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.put(LanguageController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          languageController.t('privacy'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            """AVISO DE PRIVACIDAD INTEGRAL
En cumplimiento con lo dispuesto por la Ley Federal de Protección de Datos Personales en Posesión de los Particulares, el presente Aviso de Privacidad tiene por objeto informar al titular de los datos personales sobre la manera en que se recaban, utilizan, almacenan, transfieren y protegen los datos personales por parte de ALEJANDRO LOIS PÉREZ, quien actúa bajo el nombre comercial de INVERX, en lo sucesivo denominado “EL RESPONSABLE”.
1. IDENTIDAD Y DOMICILIO DEL RESPONSABLE
EL RESPONSABLE, opera comercialmente bajo la denominación INVERX, con domicilio en Puebla, México. Para todos los efectos relacionados con el presente Aviso de Privacidad, se entenderá que INVERX es responsable del tratamiento de los datos personales que recabe a través de su aplicación digital, sitio web y demás medios electrónicos o físicos.
2. DATOS PERSONALES RECABADOS
Los datos personales que INVERX podrá recabar incluyen, de manera enunciativa más no limitativa: nombres, teléfonos, direcciones, correos electrónicos, datos bancarios como cuentas bancarias, datos biométricos e identificaciones oficiales. Dichos datos serán tratados conforme a los principios de licitud, consentimiento, información, calidad, finalidad, lealtad, proporcionalidad y responsabilidad.
3. FINALIDADES DEL TRATAMIENTO DE DATOS PERSONALES
Los datos personales que se recaben serán utilizados para las siguientes finalidades primarias: 
(a) Validar la identidad de los usuarios de la aplicación INVERX; 
(b) Procesar y realizar pagos entre compradores y vendedores; 
(c) Enviar notificaciones y comunicaciones relacionadas con las operaciones realizadas; 
(d) Contactar a los usuarios por chat, correo electrónico o llamadas telefónicas con fines operativos o de verificación.
De manera adicional, INVERX podrá utilizar los datos personales para fines secundarios como: 
(i) ofrecer promociones, beneficios o actualizaciones del servicio; 
(ii) realizar encuestas de satisfacción; y 
(iii) mejorar la funcionalidad y experiencia de usuario dentro de la aplicación.
4. TRANSFERENCIA DE DATOS PERSONALES
INVERX podrá compartir los datos personales con terceros únicamente en los siguientes casos: 
(a) Con instituciones bancarias para el procesamiento de pagos y transferencias; 
(b) Con proveedores de servicios logísticos o de envío para la entrega de bienes; 
(c) Con autoridades competentes cuando así lo exija la legislación aplicable o una orden judicial.
En todos los casos, INVERX garantizará que dichos terceros asuman las mismas obligaciones de confidencialidad y protección de datos establecidas en el presente Aviso.
5. DERECHOS ARCO (ACCESO, RECTIFICACIÓN, CANCELACIÓN Y OPOSICIÓN)
El titular de los datos personales podrá ejercer en cualquier momento sus derechos de Acceso, Rectificación, Cancelación u Oposición (ARCO), así como revocar el consentimiento otorgado para el tratamiento de sus datos personales, mediante solicitud enviada al siguiente medio de contacto:
[MEDIO DE CONTACTO — CORREO ELECTRÓNICO O DOMICILIO FÍSICO PENDIENTE DE DEFINIR]
La solicitud deberá contener el nombre del titular, los datos de contacto, una descripción clara de los datos respecto de los cuales se busca ejercer alguno de los derechos ARCO, y cualquier otro elemento que facilite su localización.
6. MEDIDAS DE SEGURIDAD
INVERX implementa las medidas de seguridad administrativas, técnicas y físicas necesarias para proteger los datos personales contra daño, pérdida, alteración, destrucción o uso no autorizado. El acceso a los datos personales está restringido únicamente al personal autorizado que requiere conocer dicha información para el cumplimiento de las finalidades establecidas en este Aviso.
7. CAMBIOS AL AVISO DE PRIVACIDAD
INVERX se reserva el derecho de realizar modificaciones o actualizaciones al presente Aviso de Privacidad en cualquier momento, las cuales serán notificadas a través de su aplicación digital o sitio web. Dichas modificaciones estarán disponibles para consulta en la sección correspondiente de privacidad y protección de datos.
8. JURISDICCIÓN Y LEGISLACIÓN APLICABLE
Para la interpretación y cumplimiento del presente Aviso de Privacidad, las partes se someten expresamente a las leyes y tribunales competentes de la ciudad de Puebla, México, renunciando a cualquier otro fuero que pudiera corresponderles por razón de su domicilio presente o futuro.

El presente Aviso de Privacidad fue actualizado por última vez en [FECHA DE ACTUALIZACIÓN] y se encuentra disponible para todos los usuarios de la aplicación INVERX en su versión vigente.
""",
            style: TextStyle(fontSize: 14, color: Color(0xFFE0E0E0)),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
