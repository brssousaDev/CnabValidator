# **ADR-001 - Migração do back-end do CNAB Validator de Quarkus para Spring Boot**: 

# **Contexto**: 

O sistema CNAB Validator possui um backend desenvolvido em Quarkus 3.x utilizando Java 17 para disponibilizar APIs REST responsáveis pela validação, visualização e exportação de arquivos CNAB.

Durante a utilização da aplicação em ambiente corporativo foram identificadas restrições de governança e infraestrutura relacionadas ao download e gerenciamento de dependências do ecossistema Quarkus através dos repositórios Maven corporativos.

Essas restrições aumentam o esforço operacional para manutenção, atualização de versões, correções de vulnerabilidades e onboarding de novos desenvolvedores.

Além disso, o ecossistema Spring Boot já é amplamente adotado na organização, possuindo maior suporte interno, padronização arquitetural e menor atrito operacional.

#  **Decisão**: 

Migrar o backend do CNAB Validator de Quarkus para Spring Boot 3.x mantendo:

Java 17  
APIs REST existentes  
Contratos JSON atuais  
Estrutura de processamento CNAB  
Parser YAML baseado em SnakeYAML  
Arquitetura stateless

A migração deverá preservar o comportamento funcional da aplicação sem alterações para o frontend Flutter.

**Consequências Positivas**  
Maior aderência aos padrões tecnológicos adotados pela organização.  
Redução de problemas relacionados à obtenção de dependências e artefatos.  
Maior disponibilidade de documentação e suporte da comunidade.  
Facilidade para contratação e capacitação de desenvolvedores.  
Maior integração com ferramentas corporativas já utilizadas pela empresa.  
Simplificação da manutenção evolutiva do produto.

**Consequências Negativas**  
Esforço inicial de migração e testes.  
Necessidade de adaptação das configurações específicas do Quarkus para Spring Boot.  
Possível aumento do consumo de memória da aplicação.  
Possível aumento do tempo de inicialização da aplicação.  
Necessidade de atualização da documentação técnica e pipelines de build.

#  Justificativa da decisão

Embora o Quarkus apresente vantagens relacionadas a performance de inicialização e consumo de recursos, esses benefícios não são críticos para o contexto atual do CNAB Validator, uma aplicação sem requisitos de alta escala ou processamento distribuído.

A redução do custo operacional e o alinhamento com o padrão tecnológico corporativo justificam a adoção do Spring Boot como framework padrão para evolução futura da aplicação.

Essa justificativa costuma ser muito bem aceita em revisões de ADR porque demonstra que a decisão foi tomada por critérios de negócio e operação, e não apenas por preferência tecnológica.