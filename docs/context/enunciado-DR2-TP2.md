# Enunciado — DR2 · TP2 (Teste de Performance)

- **Disciplina:** Sistemas Operacionais com Linux e Python
- **Bloco:** Ciência da Computação
- **Turma:** GRLENGR2C2-N2-L1
- **Trimestre:** 26E4_2
- **Professor:** Leonardo Silva da Gloria
- **Instituição:** Instituto Infnet

Texto do enunciado, na íntegra, como foi entregue pela disciplina.

---

Este Teste de Performance avalia sua capacidade de operar o sistema operacional Linux por meio da linha de comando e de investigar como o Linux interage com o hardware e os dispositivos do sistema, utilizando exclusivamente ferramentas de terminal.

Siga cuidadosamente as instruções de cada exercício e capture screenshots após a execução de cada tarefa, pois eles servirão como evidência objetiva do seu trabalho.

Além dos screenshots, ao final deste Teste de Performance, você deverá gravar um vídeo com duração entre 4 e 6 minutos, no qual deverá:

* Explicar, com suas próprias palavras, o que foi realizado em cada conjunto de exercícios
* Demonstrar no terminal os principais comandos utilizados
* Comentar brevemente a finalidade de cada comando no contexto da investigação de hardware e dispositivos no Linux

## Exercício 1 Shell expansions

**Contexto:** Shell expansions permitem criar comandos mais eficientes e expressivos, reduzindo repetição e aumentando produtividade em ambientes computacionais.

**Tarefa do aluno**

1. Utilize expansões de shell para listar arquivos com extensão .log
2. Utilize expansões para criar múltiplos arquivos simultaneamente
3. Registre os comandos e resultados em expansoes.txt

## Exercício 2 Pipelines e redirecionamento básico

**Contexto:** Pipelines permitem combinar comandos simples para formar operações mais expressivas, sendo amplamente utilizados em automação e análise de sistemas.

**Tarefa do aluno**

1. Liste os arquivos do diretório /etc
2. Utilize um pipeline para paginar a saída
3. Redirecione o resultado para um arquivo chamado pipeline.txt
4. Verifique o conteúdo utilizando less

## Exercício 3 Pipelines para inspeção de dispositivos

**Contexto:** A inspeção de dispositivos expostos pelo kernel é frequentemente realizada combinando comandos simples por meio de pipelines.

**Tarefa do aluno**

1. Liste todos os arquivos presentes no diretório /dev
2. Utilize um pipeline para filtrar apenas dispositivos do tipo bloco
3. Redirecione o resultado para um arquivo chamado dispositivos_bloco.txt
4. Verifique o conteúdo do arquivo utilizando less

## Exercício 4 Redirecionamento e abstração de dispositivos

**Contexto:** No Linux, dispositivos são tratados como arquivos especiais, permitindo redirecionamento de dados da mesma forma que arquivos comuns.

**Tarefa do aluno**

1. Execute um comando simples que gere saída textual
2. Redirecione essa saída para o dispositivo especial /dev/null
3. Execute novamente o comando sem redirecionamento
4. Registre em redirecionamento.txt os comandos utilizados e a diferença observada

## Exercício 5 Uso correto de aspas no shell

**Contexto:** Aspas simples e duplas possuem comportamentos distintos no shell, afetando expansão e interpretação de strings.

**Tarefa do aluno**

1. Utilize echo com aspas simples e duplas para imprimir textos diferentes
2. Demonstre um caso em que o comportamento muda
3. Registre comandos e resultados em aspas.txt

## Exercício 6 Exploração do sysfs

**Contexto:** O sysfs é uma interface fundamental entre o kernel e o espaço de usuário, expondo informações sobre dispositivos e subsistemas.

**Tarefa do aluno**

1. Liste os dispositivos de bloco disponíveis em /sys/block
2. Escolha um dispositivo listado
3. Leia ao menos dois atributos desse dispositivo no sysfs
4. Registre comandos e saídas em sysfs.txt

## Exercício 7 Metadados de dispositivos com udev

**Contexto:** O udev gerencia a criação dinâmica de arquivos de dispositivo e seus metadados.

**Tarefa do aluno**

1. Identifique um dispositivo de armazenamento presente em /dev
2. Utilize udevadm info para inspecionar seus metadados
3. Redirecione a saída para udev_info.txt
4. Destaque informações relacionadas ao tipo de dispositivo e fabricante

## Exercício 8 Mensagens do kernel e hardware

**Contexto:** O kernel registra eventos relacionados a hardware e dispositivos em logs acessíveis ao administrador.

**Tarefa do aluno**

1. Utilize journalctl -k para visualizar mensagens do kernel
2. Filtre mensagens relacionadas a dispositivos de armazenamento
3. Salve o resultado em kernel_devices.txt

## Exercício 9 Dispositivos e drivers ativos

**Contexto:** Drivers permitem que o kernel se comunique com o hardware, e o Linux disponibiliza essas informações via interfaces textuais.

**Tarefa do aluno**

1. Liste os drivers registrados no sistema utilizando /proc/devices
2. Redirecione a saída para drivers.txt
3. Identifique ao menos um driver de bloco e um de caractere

## Exercício 10 Identificação de dispositivos de armazenamento

**Contexto:** A identificação correta de discos e partições é essencial antes de qualquer operação de armazenamento.

**Tarefa do aluno**

1. Utilize lsblk para listar discos e partições
2. Execute o comando de forma que a hierarquia fique clara
3. Salve a saída em armazenamento.txt

## Exercício 11 Filesystems montados

**Contexto:** Filesystems conectam dispositivos de armazenamento à estrutura lógica de diretórios.

**Tarefa do aluno**

1. Utilize o comando mount para listar filesystems montados
2. Redirecione a saída para filesystems.txt
3. Utilize df para complementar a análise de uso de espaço

## Exercício 12 Integração de comandos para análise de dispositivo de armazenamento

**Contexto:** A análise de dispositivos de armazenamento em ambientes profissionais exige a integração de múltiplos comandos para identificação, interpretação e documentação técnica.

**Tarefa do aluno**

1. Identifique um dispositivo de armazenamento disponível no sistema
2. Utilize pipelines para isolar informações referentes apenas a esse dispositivo
3. Analise o dispositivo a partir das seguintes perspectivas:
   a) Representação no diretório /dev
   b) Reconhecimento pelo kernel e suas partições
   c) Organização na hierarquia de block devices
4. Utilize redirecionamento de saída para registrar separadamente cada etapa
5. Utilize ao menos um comando auxiliar para investigar um dos comandos utilizados
6. Consolide todas as informações em analise_final.txt, organizando o conteúdo por seções, indicando:
   * comandos executados
   * finalidade de cada comando
   * principais informações obtidas

## Entrega

Ao finalizar todos os exercícios:

1. Reúna todos os screenshots e os arquivos de evidência (.txt) gerados durante a execução das tarefas em um único arquivo PDF
2. Nomeie o arquivo conforme o padrão: nome_sobrenome_DR2_TP2.PDF
3. Poste o PDF como resposta a este Teste de Performance no ambiente da disciplina
