import 'package:flutter/material.dart';


class TermsServicePage extends StatefulWidget {
  const TermsServicePage({super.key});

  @override
  State<TermsServicePage> createState() => TermsServicePageState();
}
class TermsServicePageState extends State<TermsServicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Termos de Serviço'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Termos de Serviço da AgrInnovate',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Última Atualização: [22-11-2024]',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(
              'Bem-vindo à AgrInnovate! Estes Termos de Serviço ("Termos") regulam o uso da nossa aplicação que oferece monitoramento ambiental em tempo real, incluindo fatores como temperatura, umidade do ar, intensidade da luz, velocidade e direção do vento, e precipitação. Ao usar nossa aplicação, você concorda em cumprir estes Termos. Caso não concorde com algum destes Termos, não utilize o serviço.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSectionTitle('1. Aceitação dos Termos'),
            _buildSectionContent(
                'Ao aceder ou utilizar a aplicação AgrInnovate, você concorda em estar vinculado a estes Termos e à nossa Política de Privacidade. Caso não concorde com qualquer um dos Termos, você deve interromper o uso da aplicação imediatamente.'),
            _buildSectionTitle('2. Descrição do Serviço'),
            _buildSectionContent(
                'A aplicação AgrInnovate permite que você monitore variáveis ambientais em tempo real, como temperatura, umidade, luz, vento e precipitação, para otimizar suas práticas agrícolas e tomar decisões mais informadas sobre o manejo de culturas. Através de sensores e dispositivos conectados, os dados são transmitidos para seu dispositivo e disponibilizados por meio de um aplicativo.'),
            _buildSectionTitle('3. Requisitos de Uso'),
            _buildSectionContent(
                'Para utilizar a aplicação AgrInnovate, você deve:\n\n- Ser maior de idade ou ter o consentimento de um responsável legal.\n- Fornecer informações precisas ao criar uma conta, se aplicável.\n- Manter a confidencialidade da sua conta e senha.\n- Ter acesso a um dispositivo compatível com a aplicação e à internet.'),
            _buildSectionTitle('4. Licença de Uso'),
            _buildSectionContent(
                'A AgrInnovate concede uma licença limitada, não exclusiva e intransferível para usar a aplicação de acordo com estes Termos. Você não pode copiar, modificar, distribuir ou revender a aplicação sem a nossa permissão expressa por escrito.'),
            _buildSectionTitle('5. Propriedade Intelectual'),
            _buildSectionContent(
                'Todos os direitos de propriedade intelectual relacionados à AgrInnovate, incluindo mas não se limitando a, designs, logos, código-fonte e conteúdos fornecidos, pertencem à AgrInnovate ou aos seus licenciantes. Nenhum direito de propriedade intelectual é transferido a você ao usar a aplicação.'),
            _buildSectionTitle('6. Responsabilidade do Usuário'),
            _buildSectionContent(
                'Você é responsável por:\n\n- Utilizar a aplicação de maneira legal e em conformidade com os Termos.\n- Garantir que os dispositivos de monitoramento estejam corretamente instalados e funcionando.\n- Verificar a precisão dos dados fornecidos pela aplicação antes de tomar decisões críticas baseadas neles.\n- Não utilizar a aplicação para fins ilegais ou de maneira que prejudique outros usuários ou o serviço.'),
            _buildSectionTitle('7. Proibições'),
            _buildSectionContent(
                'Você não deve:\n\n- Tentar obter acesso não autorizado à aplicação ou aos dados dos usuários.\n- Usar a aplicação para fins fraudulentos ou ilegais.\n- Interferir no funcionamento dos sistemas da aplicação ou tentar desabilitar seus dispositivos.'),
            _buildSectionTitle('8. Privacidade e Coleta de Dados'),
            _buildSectionContent(
                'A sua privacidade é importante para nós. Coletamos dados relacionados ao uso da aplicação e informações dos sensores, como temperatura, umidade, e outros dados ambientais. Estes dados são usados para melhorar o serviço e são regidos pela nossa Política de Privacidade, que você deve ler e compreender. Ao usar a aplicação, você concorda com a coleta e uso de seus dados conforme descrito na nossa política.'),
            _buildSectionTitle('9. Modificação dos Termos'),
            _buildSectionContent(
                'Podemos modificar estes Termos a qualquer momento. Você será notificado sobre mudanças significativas através de um aviso na aplicação ou por e-mail. O uso contínuo da aplicação após a modificação dos Termos constitui a aceitação das alterações.'),
            _buildSectionTitle('10. Limitação de Responsabilidade'),
            _buildSectionContent(
                'A AgrInnovate não se responsabiliza por danos indiretos, incidentais ou consequenciais decorrentes do uso da aplicação, incluindo, mas não se limitando a, falhas nos dados, interrupções do serviço ou danos aos dispositivos de monitoramento.'),
            _buildSectionTitle('11. Suspensão ou Encerramento de Conta'),
            _buildSectionContent(
                'Podemos suspender ou encerrar sua conta caso você viole estes Termos ou use a aplicação de forma inadequada. Você será notificado sobre a suspensão ou encerramento de sua conta sempre que possível.'),
            _buildSectionTitle('12. Lei Aplicável e Resolução de Disputas'),
            _buildSectionContent(
                'Estes Termos são regidos pelas leis de [Seu País/Estado]. Caso haja qualquer disputa relacionada ao uso da aplicação, as partes concordam em buscar resolução amigável, sendo que, caso não seja possível, a disputa será resolvida por arbitragem ou outro método alternativo de resolução de disputas.'),
            _buildSectionTitle('13. Disposições Finais'),
            _buildSectionContent(
                'Caso qualquer parte destes Termos seja considerada inválida ou inaplicável, as demais disposições continuarão em pleno vigor. Estes Termos constituem o acordo integral entre você e a AgrInnovate.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}