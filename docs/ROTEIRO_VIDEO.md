# Roteiro do vídeo · DR2-TP2 (4 a 6 minutos)

O enunciado pede um vídeo de 4 a 6 minutos com três coisas: explicar, com as minhas palavras, o que
fiz em cada conjunto de exercícios; demonstrar no terminal os principais comandos; e comentar a
finalidade de cada comando na investigação de hardware e dispositivos.

**Preparação.** Abrir o Ubuntu no Windows Terminal, com fonte grande, e rodar `cd ~/DR2_TP2`. Os
arquivos dos exercícios já estão lá. O disco de laboratório só é necessário se eu quiser repetir o
Ex. 10; nesse caso, rodar `sudo losetup -fP --show ex10_armazenamento/disco_lab.img` e, ao final,
`sudo losetup -d /dev/loopN`.

| Tempo | Bloco | O que falar | O que digitar |
|---|---|---|---|
| 0:00–0:30 | Abertura | Quem sou, a disciplina e o objetivo: operar o shell e investigar como o Linux expõe o hardware. Ambiente: Ubuntu no WSL2, com discos virtuais do Hyper-V. | `uname -r` · `findmnt -no SOURCE /` |
| 0:30–1:30 | Shell (Ex. 1 a 5) | Expansões são feitas pelo shell antes do comando: chaves geram nomes e curingas casam com o que existe. Pipe liga comandos; `>`, `<` e `2>` desviam os fluxos; `/dev/null` é um dispositivo que descarta dados. Aspas duplas expandem variáveis; simples, não. | `echo /dev/sd{a..h}` · `echo /dev/sd?` · `ls -l /dev \| grep '^b' \| head` · `uname -a > /dev/null; echo $?` · `echo 'Kernel: $(uname -r)'` · `echo "Kernel: $(uname -r)"` |
| 1:30–3:00 | Kernel e dispositivos (Ex. 6 a 9) | O sysfs mostra os atributos que o kernel mantém para cada dispositivo; o udev cria o arquivo em `/dev` e guarda metadados como fabricante e modelo; o journal guarda o que o kernel registrou ao detectar os discos; `/proc/devices` liga o número *major* ao driver. Ponto de interpretação: o disco se declara rotacional, mas o arquivo está num SSD. | `cat /sys/block/sdf/size` · `cat /sys/block/sdf/queue/rotational` · `udevadm info -q property -n /dev/sdf \| grep -E 'ID_(VENDOR\|MODEL\|BUS)='` · `journalctl -k -b \| grep -w sdf` · `grep -E '^ *(1\|8) ' /proc/devices` · `ls -l /dev/sdf /dev/null` |
| 3:00–4:15 | Armazenamento (Ex. 10 e 11) | O `lsblk` mostra a árvore de block devices. Os discos do WSL não têm partições, então criei um disco de laboratório com duas partições para ver a hierarquia. O `mount` mostra onde cada filesystem está ligado à árvore; o `df` mostra o espaço. | `cat armazenamento.txt` · `grep -E '^/dev/' filesystems.txt` · `df -hT -x tmpfs` |
| 4:15–5:30 | Análise integrada (Ex. 12) | Um disco, três perspectivas: o arquivo em `/dev`, o reconhecimento pelo kernel e a posição na hierarquia. Cada etapa foi gravada num arquivo próprio com `>` e consolidada em `analise_final.txt`. Usei `whatis` e `man` para investigar o `lsblk`. | `ls ex12_analise` · `cat ex12_analise/etapa2_kernel.txt` · `whatis lsblk` · `less analise_final.txt` |
| 5:30–6:00 | Fechamento | O que aprendi: no Linux, tudo o que o kernel sabe sobre o hardware está em arquivos de texto, e o shell é a ferramenta para cruzar essas fontes. | — |

Dica: falar enquanto o comando roda, sem ler o roteiro, e manter cada bloco no tempo indicado.
