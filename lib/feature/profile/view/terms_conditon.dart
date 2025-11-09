import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../core/language/language_controller.dart';

class TermsConditionScreenView extends StatelessWidget {
  const TermsConditionScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.put(LanguageController());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          languageController.t('terms'),
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
            """TÉRMINOS Y CONDICIONES DE USO DE LA APP

1. Introducción

Bienvenido a InverX . Estos términos y condiciones regulan el uso de nuestra plataforma, donde ofrecemos servicios de terceros, venta de productos nuevos y de segunda mano, así como gestión de transacciones.

2. Servicios

Nos comprometemos a facilitar la distribución del dinero y a hacer las transacciones más seguras entre los usuarios, actuando como intermediario en los pagos.

3. Responsabilidad del manejo de dinero

La plataforma solo se responsabiliza de guardar el dinero de los usuarios hasta que se cumplan los requisitos acordados para la entrega o prestación del servicio. No somos responsables por la calidad, legalidad o autenticidad de los productos y servicios ofrecidos por terceros. El manejo y la liberación del dinero se realizará únicamente conforme a los acuerdos establecidos en la plataforma y tras verificar que se cumplen los requisitos de la transacción.

4. Comisión

La comisión por cada transacción será del 5% del monto total, que será retenido por la plataforma al momento del pago.

5. Uso de la plataforma

El usuario acepta usar la plataforma de forma responsable y conforme a la ley. Está prohibido publicar contenido ilícito, ofensivo o que infrinja derechos de terceros.

6. Responsabilidades del usuario

El usuario reconoce que la plataforma solo actúa como intermediario y no se responsabiliza por posibles disputas, daños, pérdidas o cualquier problema derivado de las transacciones o la calidad de los productos o servicios.

7. Limitación de responsabilidad

En la medida máxima permitida por la ley, InverX no será responsable por daños directos, indirectos, incidentales, especiales, consecuentes o ejemplares que puedan derivarse del uso de la plataforma, productos o servicios ofrecidos.

8. Exención de responsabilidad

El usuario libera a InverX, sus directivos, empleados y colaboradores de cualquier reclamación, daño o perjuicio derivado del uso de la plataforma, pago o entrega de productos o servicios.

9. Modificaciones

Nos reservamos el derecho de modificar estos términos en cualquier momento. Es responsabilidad del usuario revisar periódicamente los términos.

10. Legislación aplicable y jurisdicción

Estos términos se rigen por las leyes de [país o jurisdicción], y cualquier disputa será sometida a los tribunales de [ciudad o región].
InverX es una compañía de tecnología que ofrece servicios vinculados principalmente al comercio electrónico, servicios y a los pagos digitales.

Para poder operar en la plataforma todas las Personas Usuarias deberán aceptar los Términos y Condiciones, los anexos y la Declaración de Privacidad.

Cada Persona Usuaria es responsable de los datos personales que brindan al momento de registrarse y se obliga a mantenerlos actualizados. Además,
es el unico responsable del uso y resguardo de su contraseña.

En algunos casos, podremos cobrar una tarifa por el uso de los servicios que integran el ecosistema de InverX, que la persona ususria se compromete a pagar.

Pódran usar nuestros servicios las personas mayores de edad que tengan la capacidad lelga

Quien quiera usar nuestros servicios, deberá completar el formulario de registro con los datos que le sean requeridos. Al completarlo, se compromete a hacerlo de manera exacta, precisa y verdadera y a mantener sus datos siempre actualizados. La Persona Usuaria será la única responsable de la certeza de sus datos de registro. Sin perjuicio de la información brindada en el formulario, podremos solicitar y/o consultar información adicional para corroborar la identidad de la Persona Usuaria. 

La cuenta es personal, única e intransferible, es decir que bajo ningún concepto se podrá vender o ceder a otra persona. Se accede a ella con la clave personal de seguridad que haya elegido y que deberá mantener bajo estricta confidencialidad. La Persona Usuaria podrá crear Cuentas Colaboradoras y definir sus permisos de acceso. En cualquier caso, la Persona Usuaria será la única responsable por las operaciones que se realicen en su cuenta. En caso de detectar un uso no autorizado de su cuenta, deberá notificar de forma inmediata y fehaciente a InverX.

Podremos rechazar una solicitud de registro o bien cancelar un registro ya aceptado, sin que esto genere derecho a un resarcimiento. No podrán registrarse nuevamente en el Sitio las Personas Usuarias que hayan sido inhabilitadas previamente. Tampoco podrán registrarse quienes estén incluidos o relacionados a personas incluidas en listas nacionales o internacionales de sanciones. 

Además, en caso de detectar el uso de más de una cuenta, podremos aplicar retenciones, débitos y/o cualquier otra medida si consideramos que ese accionar puede perjudicar al resto de las personas que usan el Sitio o a InverX, más allá de las sanciones que pudieran corresponder.

“Información Comercial” es toda información provista y/o generada por las Personas Usuarias al utilizar los servicios de la app, incluyendo sin limitación datos de productos vendidos, precios, ventas, ratings, volumen, número de visitas, tasas de conversión y fecha de transacciones en los sitios de InverX. Al momento de proveer y/o generarse esta Información Comercial en el Sitio Web o APP de InverX, las Personas Usuarias reconocen que InverX podrá usar esa información. Conoce más sobre nuestra política de Acceso a Información Comercial.

Sanciones
En caso que la Persona Usuaria incumpliera una ley o los Términos y Condiciones, podremos advertir, suspender, restringir o inhabilitar temporal o definitivamente su cuenta, sin perjuicio de otras sanciones que se establezcan en las reglas de uso particulares de los servicios de InverX. 

Responsabilidad
InverX será responsable por cualquier defecto en la prestación de su servicio, en la medida en que le sea imputable y con el alcance previsto en las leyes vigentes. 

InverX podrá cobrar por sus servicios y la Persona Usuaria se compromete a pagarlos a tiempo. 

Podremos modificar o eliminar las tarifas en cualquier momento con el debido preaviso establecido en la cláusula 2 de estos Términos y Condiciones. De la misma manera, podremos modificar las tarifas temporalmente por promociones en favor de las Personas Usuarias. 

La Persona Usuaria autoriza a InverX a retener y/o debitar los fondos existentes y/o futuros de su cuenta de InverX y/o de las cuentas bancarias que haya registrado en ella, para saldar las tarifas impagas o cualquier otra deuda que pudiera tener. 

Para conocer el detalle de las tarifas de cada servicio, las Personas Usuarias deberán consultar los términos y condiciones correspondientes. 

En todos los casos se emitirá la factura de conformidad con los datos fiscales que las personas tengan cargados en su cuenta.  

Propiedad Intelectual
InverX y/o sus sociedades relacionadas son propietarias de todos los derechos de propiedad intelectual sobre sus sitios, todo su contenido, servicios, productos, marcas, nombres comerciales, logos, diseños, imágenes, frases publicitarias, derechos de autor, dominios, programas de computación, códigos, desarrollos, software, bases de datos, información, tecnología, patentes y modelos de utilidad, diseños y modelos industriales, secretos comerciales, entre otros (“Propiedad Intelectual”) y se encuentran protegidos por leyes nacionales e internacionales.

Aunque InverX otorga permiso para usar sus productos y servicios conforme a lo previsto en los Términos y Condiciones, esto no implica una autorización para usar su  Propiedad Intelectual, excepto consentimiento previo y expreso de InverX y/o sus sociedades vinculadas. En cualquier caso, los usuarios vendedores que usen dichos productos y servicios no podrán utilizar la Propiedad Intelectual de InverX de una manera que cause confusión en el público y deberán llevar a cabo su actividad comercial bajo una marca o nombre comercial propio y distintivo, que no resulte confundible con la marca InverX y su familia de marcas “InverX”, siguiendo con los lineamientos del marco legal nacional e internacional

Está prohibido usar nuestros productos o servicios para fines ilegales, realizar cualquier tipo de ingeniería inversa u obras derivadas, utilizar herramientas de búsqueda o de extracción de datos y contenidos de nuestra plataforma para su reutilización y/o crear bases de datos propias que incluyan en todo o en parte nuestro contenido sin nuestra expresa autorización. Está también prohibido el uso indebido, sin autorización y/o contrario a la normativa vigente y/o que genere confusión o implique uso denigratorio y/o que le cause perjuicio, daños o pérdidas a InverX y/o a sus sociedades relacionadas. La utilización de los productos y servicios de InverX tampoco implica la autorización para usar propiedad intelectual de terceros que pueda estar involucrada, cuyo uso quedará bajo exclusiva responsabilidad del usuario. 
En caso que una Persona Usuaria o cualquier publicación infrinja la Propiedad Intelectual de InverX o de terceros, InverX podrá remover dicha publicación total o parcialmente), sancionar al usuario conforme a lo previsto en estos Términos y Condiciones y ejercer las acciones extrajudiciales y/o judiciales correspondientes.

La Persona Usuaria mantendrá indemne a ‌verX y sus sociedades relacionadas, así como a quienes la dirigen, suceden, administran, representan y/o trabajan en ellas, por cualquier reclamo administrativo o judicial iniciado por otras Personas Usuarias, terceros o por cualquier Organismo, relacionado con sus actividades en el.
En virtud de esa responsabilidad, podrán realizar compensaciones, retenciones u otras medidas necesarias para la reparación de pérdidas, daños y perjuicios, cualquiera sea su naturaleza.



""",
            style: TextStyle(fontSize: 14, color: Color(0xFFE0E0E0)),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
