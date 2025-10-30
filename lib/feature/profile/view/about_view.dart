import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(title: Text("About App",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w700),),
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.black,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text("""CONTRATO DE INTERMEDIACIÓN FINANCIERA
En la ciudad de Puebla, México, a la fecha de firma que al calce se indique, se celebra el presente CONTRATO DE INTERMEDIACIÓN FINANCIERA, que suscriben por una parte el C. ALEJANDRO LOIS PÉREZ, en lo sucesivo denominado “EL INTERMEDIARIO”, y por la otra parte, la persona física o moral que utilice sus servicios, en lo sucesivo denominada “EL CLIENTE”, conforme a las siguientes declaraciones y cláusulas:
DECLARACIONES
I. Declara EL INTERMEDIARIO, ser una persona física, de nacionalidad Mexicana, mayor de edad, con capacidad legal y material para celebrar el presente contrato, y que cuenta con la experiencia necesaria para desempeñar funciones de intermediación financiera entre compradores y prestadores de servicios o vendedores.
II. Declara EL CLIENTE, ser una persona física o moral con capacidad jurídica para obligarse en los términos de este contrato y que desea hacer uso de los servicios del INTERMEDIARIO.
III. Ambas partes declaran que celebran el presente contrato de buena fe y con plena capacidad jurídica.
CLÁUSULAS
PRIMERA. OBJETO.- El presente contrato tiene por objeto que EL INTERMEDIARIO actúe como enlace entre EL CLIENTE y los prestadores de servicios o vendedores, recibiendo los fondos del CLIENTE mediante la aplicación electrónica denominada INVERX, y liberándolos al prestador del servicio o vendedor una vez que éste haya entregado el artículo o concluido satisfactoriamente el servicio pactado.

SEGUNDA. HONORARIOS.- EL INTERMEDIARIO percibirá como contraprestación por sus servicios una comisión equivalente al cinco por ciento (5%) del valor total del producto o servicio contratado. Dicho monto será retenido directamente por EL INTERMEDIARIO al momento de recibir el pago del CLIENTE mediante la aplicación electrónica INVERX.
TERCERA. CONFIDENCIALIDAD.- EL INTERMEDIARIO se obliga a mantener absoluta confidencialidad respecto de toda la información, datos o documentos a los que tenga acceso con motivo de la ejecución del presente contrato, comprometiéndose a no divulgar ni utilizar dicha información para fines distintos a los aquí establecidos, salvo autorización expresa y por escrito de EL CLIENTE.
CUARTA. RESPONSABILIDAD.- EL INTERMEDIARIO actuará como mero intermediario entre las partes, por lo que no será responsable por incumplimientos, defectos, daños o vicios en los productos o servicios prestados por los vendedores o prestadores de servicios, así como de la legal procedencia de los recursos económicos con los que sean pagados los productos y o servicios comercializados a través de INVERX, limitándose su responsabilidad a la correcta recepción, custodia y liberación de los fondos.
QUINTA. PROTECCIÓN DE DATOS PERSONALES.- EL INTERMEDIARIO se compromete a tratar los datos personales de EL CLIENTE y de los terceros involucrados conforme a lo dispuesto por la Ley Federal de Protección de Datos Personales en Posesión de los Particulares, garantizando su resguardo, confidencialidad y uso exclusivamente para los fines de este contrato.
SEXTA. PREVENCIÓN DE OPERACIONES CON RECURSOS DE PROCEDENCIA ILÍCITA.- EL INTERMEDIARIO manifiesta que no realiza actividades propias de las entidades reguladas por la Ley Federal para la Prevención e Identificación de Operaciones con Recursos de Procedencia Ilícita, actuando únicamente como intermediario entre las partes. En consecuencia, EL INTERMEDIARIO no será responsable del origen de los fondos entregados por EL CLIENTE o los terceros, siendo obligación de cada parte asegurarse de que sus recursos provengan de actividades lícitas. EL CLIENTE libera expresamente a EL INTERMEDIARIO de cualquier responsabilidad derivada de investigaciones o procedimientos relacionados con el origen de los fondos.
SÉPTIMA. VIGENCIA.- El presente contrato tendrá vigencia indefinida a partir de la fecha de su firma, pudiendo cualquiera de las partes darlo por terminado mediante notificación por escrito con al menos cinco días hábiles de anticipación.
OCTAVA. JURISDICCIÓN Y LEGISLACIÓN APLICABLE.- Para la interpretación y cumplimiento del presente contrato, las partes se someten expresamente a las leyes y tribunales competentes de la ciudad de Puebla, México, renunciando a cualquier otro fuero que pudiera corresponderles por razón de su domicilio presente o futuro.





"""
            ,style: TextStyle(fontSize: 14,color: Color(0xFFE0E0E0),),textAlign: TextAlign.justify,),
        ),
      ),
    );
  }
}
