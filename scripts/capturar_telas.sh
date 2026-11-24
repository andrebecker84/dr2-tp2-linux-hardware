#!/usr/bin/env bash
# Executa os 12 exercicios do DR2-TP2 num terminal real (bash dentro de um tmux, no Ubuntu do WSL),
# captura cada tela e grava os arquivos de evidencia .txt.
#
#     wsl -d Ubuntu --exec bash scripts/capturar_telas.sh
#
# Cada comando e digitado no terminal como um usuario faria (tmux send-keys) e roda de verdade:
# os diretorios e arquivos dos exercicios ficam em ~/DR2_TP2. As telas saem de
# `tmux capture-pane -e` (o buffer do terminal, com cores) e viram PNG em renderizar_telas.py.
#
# Os .txt seguem o que o enunciado pede em cada exercicio. Onde ele manda REDIRECIONAR a saida
# (pipeline, dispositivos_bloco, udev_info, kernel_devices, drivers, armazenamento, filesystems e as
# etapas do Ex. 12), o arquivo e exatamente o que o redirecionamento gravou no terminal, inclusive os
# destaques acrescentados com >>. Onde ele manda REGISTRAR comandos e resultados (expansoes,
# redirecionamento, aspas, sysfs), o arquivo traz a transcricao literal do terminal e as observacoes.
# analise_final.txt consolida as etapas do Ex. 12 por secoes.
set -u

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
ANSI="$RAIZ/evidencias/telas/ansi"
COPIA="$RAIZ/evidencias/DR2_TP2"
W="$HOME/DR2_TP2"
IMG="$W/ex10_armazenamento/disco_lab.img"
S=tp2
T=(tmux -L tp2 -f "$RAIZ/scripts/tmux_tp2.conf")
WSL=/mnt/c/Windows/System32/wsl.exe
ALTURA=45           # linhas do terminal; as telas do less, man e journalctl usam ALTURA_CURTA
ALTURA_CURTA=22
FIG=0
SEG=""

# Disco analisado nos Ex. 6, 7, 9 e 12: o que guarda a raiz (/). No WSL, a letra (sdX) depende da
# ordem em que o Windows anexa os discos virtuais; por isso o roteiro descobre o nome em vez de fixa-lo.
D=$(basename "$(findmnt -no SOURCE /)")

# O disco de laboratorio do Ex. 10 fica num loop device, que so o root associa e desassocia.
# O sudo pediria senha, que o roteiro nao digita: o passo roda como root pelo proprio WSL.
como_root() { "$WSL" -d Ubuntu -u root --exec "$@"; }
solta_lab() {
    [ -f "$IMG" ] || return 0
    como_root sh -c "losetup -l -n -O NAME -j '$IMG' | xargs -r -n1 losetup -d"
}

# ------------------------------------------------------------------ estado limpo
"${T[@]}" kill-server 2>/dev/null
solta_lab
rm -rf "$W"
mkdir -p "$ANSI" "$COPIA"
# Esvazia a copia sem apagar a pasta: no lado Windows ela pode estar aberta (Explorer, OneDrive).
find "$COPIA" -mindepth 1 -delete
rm -f "$ANSI"/*.ans "$RAIZ"/evidencias/telas/*.png
: > "$ANSI/indice.txt"
cd "$HOME"

"${T[@]}" new-session -d -s $S -x 110 -y $ALTURA -c "$HOME" "bash --rcfile '$RAIZ/scripts/bashrc_tp2' -i"

espera()  { timeout 60 "${T[@]}" wait-for pronto || echo "AVISO: prompt nao voltou" >&2; }
digita()  { "${T[@]}" send-keys -t $S -l -- "$1"; "${T[@]}" send-keys -t $S Enter; }
cmd()     { digita "$1"; espera; }
# Comando lido da entrada padrao (heredoc com aspas), para linhas que misturam aspas e $.
cmdh()    { local l; IFS= read -r l; cmd "$l"; }
tecla()   { "${T[@]}" send-keys -t $S "$@"; }
altura()  { "${T[@]}" resize-window -t $S -y "$1"; sleep 0.3; }
# less, man e journalctl nao devolvem o prompt ate sair: espera a tela desenhar, captura e sai com q.
# Rodam num terminal mais baixo (ou na altura pedida no 4o argumento).
interativo() {
    altura "${4:-$ALTURA_CURTA}"
    digita "$1"; sleep "${3:-1.5}"; tela "$2"; tecla q; espera
    altura $ALTURA
}

tela() {
    FIG=$((FIG + 1))
    local nome; nome=$(printf '%02d-%s' "$FIG" "$1")
    "${T[@]}" capture-pane -t $S -e -p > "$ANSI/$nome.ans"
    echo "$nome" >> "$ANSI/indice.txt"
}

# Transcricao do trecho atual, sem as linhas vazias do fim nem o prompt ocioso.
transcreve() {
    SEG+="$("${T[@]}" capture-pane -t $S -p -J -S - -E - | awk '
        { l[NR] = $0 }
        END { n = NR
              while (n > 0 && (l[n] ~ /^[[:space:]]*$/ || l[n] ~ /\$ *$/)) n--
              for (i = 1; i <= n; i++) print l[i] }')"$'\n'
}
limpa()   { cmd clear; "${T[@]}" clear-history -t $S; }
proxima() { transcreve; limpa; }
inicio()  { SEG=""; limpa; }

DISTRO=$(. /etc/os-release; echo "$PRETTY_NAME")
BASHV=$(bash --version | head -n1 | sed -E 's/.*version ([0-9.]+).*/bash \1/')
TRACO='--------------------------------------------------------------------------------'

# grava ARQUIVO "Exercicio N - Titulo" [registro: 1 = inclui a transcricao da sessao] <<< corpo
grava() {
    local arq="$W/$1" titulo="$2" registro="${3:-1}"
    {
        echo "DR2-TP2 · $titulo"
        echo "André Luis Becker · $DISTRO (WSL2) · $BASHV · $(date '+%d/%m/%Y %H:%M')"
        echo "$TRACO"
        if [ "$registro" = 1 ]; then
            echo "REGISTRO DA SESSÃO (comandos e saídas, na ordem de execução)"
            printf '%s' "$SEG"
            echo "$TRACO"
        fi
        cat
    } > "$arq"
}

# Espera o primeiro prompt do bash.
espera
limpa

# =============================================================================== Exercicio 1
inicio
cmd '# Exercício 1 - expansões do shell'
cmd 'mkdir -v ~/DR2_TP2 && cd ~/DR2_TP2'
cmd 'mkdir -v ex01_expansoes && cd ex01_expansoes'
cmd 'touch {kernel,udev,disco}.log relatorio_{01..03}.txt'
cmd 'mkdir -pv backup/{2025,2026}/{jan,fev}'
cmd 'ls -F'
cmd 'ls *.log'
cmd 'echo *.log'
cmd 'ls relatorio_0[13].txt'
cmd 'ls /var/log/*.log'
cmd 'echo /dev/sd{a..h}'
cmd 'echo /dev/sd?'
cmd 'echo ~'
cmd 'echo "Logs aqui: $(ls *.log | wc -l) | 2^10 = $((2**10))"'
cmd 'cd ..'
tela ex01-expansoes
transcreve

grava expansoes.txt "Exercício 1 — Shell expansions" <<'EOF'
OBSERVAÇÕES
- Chaves (brace expansion) GERAM texto: um único touch criou 6 arquivos
  ({kernel,udev,disco}.log e relatorio_{01..03}.txt, com o zero à esquerda), e
  backup/{2025,2026}/{jan,fev} gerou as 4 combinações; o -p criou os pais.
- Curingas (globbing) CASAM com arquivos que já existem: *.log listou os logs
  do diretório e de /var/log, e [13] escolheu só relatorio_01 e relatorio_03.
- O echo *.log imprime a mesma lista do ls: quem expande é o shell, antes de
  executar o comando, e o ls só recebe os nomes prontos.
- /dev/sd{a..h} produz até sdg e sdh, que não existem; /dev/sd? devolve só os
  discos presentes. Por isso uso curingas para LISTAR e chaves para CRIAR.
- ~ (til), $(comando) e $((conta)) também são expansões: diretório pessoal,
  substituição de comando e aritmética.
EOF

# =============================================================================== Exercicio 2
inicio
cmd '# Exercício 2 - pipeline e redirecionamento'
cmd 'ls /etc'
cmd 'ls /etc | wc -l'
tela ex02-ls-etc
proxima
interativo 'ls -l /etc | less' ex02-pipeline-less
cmd 'ls -l /etc > pipeline.txt'
cmd 'wc -l < pipeline.txt'
cmd 'head -n 4 pipeline.txt'
tela ex02-redirecionamento
interativo 'less pipeline.txt' ex02-less-pipeline-txt
# pipeline.txt e o proprio resultado do redirecionamento e fica como o ls o gravou.

# =============================================================================== Exercicio 3
inicio
cmd '# Exercício 3 - pipelines para inspecionar /dev'
cmd 'ls /dev'
tela ex03-ls-dev
proxima
cmd 'ls -l /dev | head -n 6'
cmd 'ls -l /dev | tail -n +2 | cut -c1 | sort | uniq -c'
cmd "ls -l /dev | grep '^b' > dispositivos_bloco.txt"
cmd 'wc -l dispositivos_bloco.txt'
cmd "grep -E ' sd[a-z]\$' dispositivos_bloco.txt"
tela ex03-filtro-bloco
interativo 'less dispositivos_bloco.txt' ex03-less-dispositivos-bloco 1.5 34

# =============================================================================== Exercicio 4
inicio
cmd '# Exercício 4 - redirecionamento e o dispositivo /dev/null'
cmd 'ls -l /dev/null'
cmd 'uname -a'
cmd 'uname -a > /dev/null'
cmd 'echo "código de saída: $?"'
cmd 'uname -a'
cmd 'ls /etc/hostname /naoexiste > /dev/null'
cmd 'ls /etc/hostname /naoexiste 2> /dev/null'
cmd 'ls /etc/hostname /naoexiste > /dev/null 2>&1'
cmd 'echo "bytes guardados em /dev/null: $(wc -c < /dev/null)"'
tela ex04-dev-null
transcreve

grava redirecionamento.txt "Exercício 4 — Redirecionamento e abstração de dispositivos" <<'EOF'
DIFERENÇA OBSERVADA
- uname -a > /dev/null: nada apareceu no terminal, e o código de saída 0
  mostra que o comando rodou normalmente. A saída foi gravada no dispositivo
  /dev/null, que aceita a escrita e descarta os dados.
- uname -a, sem redirecionamento: a mesma linha voltou a aparecer na tela.
- O ls -l mostra /dev/null como "c" (dispositivo de caractere), major 1 e
  minor 3, do driver mem. O shell abriu esse arquivo especial com o mesmo >
  de um arquivo comum: é a abstração "tudo é arquivo" do Unix.
- O > desvia só a saída padrão (1). A mensagem de erro do arquivo inexistente
  continuou na tela até eu desviar também a saída de erro (2> e 2>&1).
- O wc -c < /dev/null leu 0 bytes: nada do que foi escrito ficou guardado.
EOF

# =============================================================================== Exercicio 5
inicio
cmd '# Exercício 5 - aspas simples e duplas'
cmd "echo 'Aspas simples: o shell não interpreta nada aqui dentro'"
cmd 'echo "Aspas duplas: olá, $USER"'
cmd "echo 'Usuário: \$USER | Kernel: \$(uname -r)'"
cmd 'echo "Usuário: $USER | Kernel: $(uname -r)"'
cmd 'echo Discos: /dev/sd?'
cmd 'echo "Discos: /dev/sd?"'
cmd 'MSG="disco    da    raiz"'
cmd 'echo $MSG'
cmd 'echo "$MSG"'
cmdh <<'EOF'
echo "Nas duplas: 'simples' é texto comum; \$HOME e \"aspas\" escapados"
EOF
tela ex05-aspas
transcreve

grava aspas.txt "Exercício 5 — Uso correto de aspas no shell" <<'EOF'
OBSERVAÇÕES
- Aspas simples: tudo é literal. $USER e $(uname -r) saíram como texto.
- Aspas duplas: agrupam o texto num único argumento, mas mantêm a expansão de
  variáveis ($USER) e de comandos ($(uname -r)).
- CASO EM QUE O COMPORTAMENTO MUDA: o mesmo texto "Usuário: $USER | Kernel:
  $(uname -r)" imprime becker e a versão do kernel com aspas duplas, e os
  símbolos crus com aspas simples.
- Curingas não expandem entre aspas: sem aspas, /dev/sd? virou a lista dos
  discos; com aspas duplas, ficou o texto "/dev/sd?".
- Variável sem aspas sofre divisão em palavras: echo $MSG juntou os espaços
  repetidos, e echo "$MSG" os preservou. Por isso uso "$variavel" em scripts.
- Dentro das duplas, a aspa simples é um caractere comum, e \$ e \" imprimem
  o caractere literal.
EOF

# =============================================================================== Exercicio 6
inicio
cmd '# Exercício 6 - exploração do sysfs'
cmd 'ls /sys/block'
cmd 'findmnt -no SOURCE /'
cmd "cd /sys/block/$D && ls"
cmd 'cat size'
cmd 'cat dev'
cmd 'echo "$(( $(cat size) * 512 / 1024**3 )) GiB"'
cmd 'grep . ro removable queue/{rotational,*_block_size} device/{vendor,model}'
cmd 'pwd -P'
cmd 'cd ~/DR2_TP2'
tela ex06-sysfs
transcreve

SETORES=$(cat /sys/block/$D/size)
grava sysfs.txt "Exercício 6 — Exploração do sysfs" <<EOF
DISPOSITIVO ESCOLHIDO: /dev/$D, o disco que guarda a raiz (findmnt -no SOURCE /)

ATRIBUTOS LIDOS EM /sys/block/$D
- size .....................: $SETORES setores de 512 bytes = $((SETORES * 512 / 1024**3)) GiB
- dev ......................: $(cat /sys/block/$D/dev) (major:minor; o major 8 é o driver sd)
- ro / removable ...........: $(cat /sys/block/$D/ro) / $(cat /sys/block/$D/removable) (gravável e não removível)
- queue/rotational .........: $(cat /sys/block/$D/queue/rotational) (o disco virtual se declara rotacional)
- logical/physical_block ...: $(cat /sys/block/$D/queue/logical_block_size) / $(cat /sys/block/$D/queue/physical_block_size) bytes
- device/vendor e model ....: $(cat /sys/block/$D/device/vendor | xargs) $(cat /sys/block/$D/device/model | xargs)

OBSERVAÇÕES
- O sysfs não guarda arquivos em disco: cada leitura pede o valor ao kernel,
  que o gera na hora (um valor por arquivo, em texto).
- size conta sempre setores de 512 bytes, mesmo com bloco físico de 4096.
- rotational = 1 é o que o Hyper-V informa. O arquivo .vhdx está num SSD NVMe
  do Windows: o atributo descreve o disco virtual, não a mídia física.
- pwd -P mostra o caminho real: /sys/block/$D é um link para
  /sys/devices/..., a posição do disco na árvore de barramentos (host SCSI,
  alvo, LUN e, por fim, o bloco).
EOF

# =============================================================================== Exercicio 7
inicio
cmd '# Exercício 7 - metadados de dispositivo com o udev'
cmd "ls -l /dev/$D"
cmd "ls -l /dev/disk/by-id /dev/disk/by-uuid | grep -w $D"
cmd "udevadm info --name=/dev/$D > udev_info.txt"
cmd 'wc -l udev_info.txt'
cmd 'head -n 12 udev_info.txt'
tela ex07-udevadm-info
proxima
cmd '# Destaques: tipo de dispositivo e fabricante, acrescentados com >>'
cmd "printf '\\n=== DESTAQUES: tipo e fabricante ===\\n' >> udev_info.txt"
cmd "udevadm info --name=/dev/$D | grep -E 'E: (DEVTYPE|ID_TYPE|ID_BUS|ID_VENDOR|ID_MODEL|ID_REVISION|ID_FS_TYPE)=' >> udev_info.txt"
cmd "udevadm info --attribute-walk --name=/dev/$D | grep -E 'ATTRS\\{(vendor|model|type)\\}' >> udev_info.txt"
cmd 'tail -n 12 udev_info.txt'
tela ex07-destaques

# =============================================================================== Exercicio 8
inicio
cmd '# Exercício 8 - mensagens do kernel com journalctl -k'
interativo 'journalctl -k -b' ex08-journalctl-k 2
# O pager do journalctl (less -X) deixa a pagina no terminal: limpa antes da proxima tela.
limpa
cmd 'journalctl -k -b --no-pager | wc -l'
cmdh <<'EOF'
journalctl -k -b --no-pager --no-hostname | grep -iE 'scsi|storvsc|\bsd[a-z]\b|ext4' > kernel_devices.txt
EOF
cmd 'wc -l kernel_devices.txt'
cmd "grep -w $D kernel_devices.txt"
tela ex08-filtro-armazenamento
interativo 'less -S kernel_devices.txt' ex08-less-kernel-devices 1.5 34

# =============================================================================== Exercicio 9
inicio
cmd '# Exercício 9 - drivers registrados em /proc/devices'
altura 66
cmd 'cat /proc/devices'
tela ex09-proc-devices
altura $ALTURA
proxima
cmd 'cat /proc/devices > drivers.txt'
cmd 'wc -l drivers.txt'
cmd "echo '=== Bloco: 7 loop, 8 sd, 259 blkext ===' >> drivers.txt"
cmdh <<'EOF'
sed -n '/^Block/,$p' /proc/devices | grep -E '^ *(7|8|259) ' >> drivers.txt
EOF
cmd "echo '=== Caractere: 1 mem, 4 tty, 136 pts ===' >> drivers.txt"
cmdh <<'EOF'
sed -n '/^Char/,/^$/p' /proc/devices | grep -E '^ *(1|4|136) ' >> drivers.txt
EOF
cmd "ls -l /dev/$D /dev/loop0 /dev/null /dev/zero /dev/ttyS0 >> drivers.txt"
cmd 'tail -n 16 drivers.txt'
tela ex09-identificacao

# =============================================================================== Exercicio 10
inicio
cmd '# Exercício 10 - discos e partições com lsblk'
cmd 'lsblk'
cmd 'lsblk -o NAME,MAJ:MIN,TYPE,SIZE,RO,FSTYPE,MOUNTPOINTS'
tela ex10-lsblk
proxima
cmd '# Os discos do WSL não têm partições: crio um disco de laboratório com duas'
cmd 'mkdir -v ex10_armazenamento && cd ex10_armazenamento'
cmd 'truncate -s 256M disco_lab.img'
cmdh <<'EOF'
printf 'label: gpt\nsize=96M, name=dados\nname=logs\n' | sfdisk -q disco_lab.img
EOF
cmd 'sfdisk -l disco_lab.img | tail -n 3'
LOOP=$(como_root /usr/sbin/losetup -fP --show "$IMG" | tr -d '\r')
sleep 1
cmd "# feito como root: losetup -fP --show disco_lab.img -> $LOOP"
cmd 'losetup -j disco_lab.img'
cmd "ls -l $LOOP*"
cmd 'cd ..'
cmd 'lsblk -o NAME,MAJ:MIN,TYPE,SIZE,RO,PARTLABEL,FSTYPE,MOUNTPOINTS > armazenamento.txt'
cmd 'cat armazenamento.txt'
tela ex10-hierarquia

# =============================================================================== Exercicio 11
inicio
cmd '# Exercício 11 - filesystems montados'
cmd 'mount > filesystems.txt'
cmd 'wc -l filesystems.txt'
cmd "grep -E '^/dev/' filesystems.txt"
cmd "grep -o ' type [^ ]*' filesystems.txt | sort | uniq -c | sort -rn | head -n 6"
cmd 'findmnt /'
tela ex11-mount
proxima
cmd 'df -hT -x tmpfs'
cmd 'df -i /'
cmdh <<'EOF'
{ echo; echo '=== df -hT: uso de espaço de cada filesystem ==='; df -hT; } >> filesystems.txt
EOF
cmd 'tail -n 4 filesystems.txt'
tela ex11-df

# =============================================================================== Exercicio 12
inicio
cmd '# Exercício 12 - análise integrada de um dispositivo de armazenamento'
cmd 'mkdir -v ex12_analise && cd ex12_analise'
cmd 'findmnt -no SOURCE /'
cmd 'DISCO=$(basename "$(findmnt -no SOURCE /)"); echo "Dispositivo analisado: /dev/$DISCO"'
cmd '# a) representação no diretório /dev'
cmdh <<'EOF'
{ ls -l /dev | grep -w "$DISCO"; ls -l /dev/disk/by-id /dev/disk/by-uuid | grep -w "$DISCO"; udevadm info -q property -n "/dev/$DISCO" | grep -E '^(DEVTYPE|ID_BUS|ID_VENDOR|ID_MODEL|ID_FS_TYPE)='; } > etapa1_dev.txt
EOF
cmd 'cat etapa1_dev.txt'
tela ex12-etapa1-dev
proxima
cmd '# b) reconhecimento pelo kernel e partições'
cmdh <<'EOF'
{ grep -E '^ *8 ' /proc/devices; awk -v d="$DISCO" 'NR==1 || $4==d' /proc/partitions; echo "partições de $DISCO no sysfs: $(ls -d /sys/block/$DISCO/${DISCO}* 2>/dev/null | wc -l)"; journalctl -k -b --no-pager --no-hostname | grep -w "$DISCO"; } > etapa2_kernel.txt
EOF
cmd 'cat etapa2_kernel.txt'
tela ex12-etapa2-kernel
proxima
cmd '# c) organização na hierarquia de block devices'
cmdh <<'EOF'
{ lsblk -o NAME,MAJ:MIN,TYPE,SIZE,RO,FSTYPE,MOUNTPOINTS "/dev/$DISCO"; findmnt -S "/dev/$DISCO"; readlink -f "/sys/block/$DISCO"; } > etapa3_hierarquia.txt
EOF
cmd 'cat etapa3_hierarquia.txt'
tela ex12-etapa3-hierarquia
proxima
cmd '# comandos auxiliares para investigar o lsblk e o findmnt'
cmdh <<'EOF'
{ whatis lsblk findmnt udevadm; type lsblk findmnt; lsblk --help | grep -E -- '-o, --output|-d, --nodeps|-s, --inverse'; } > etapa4_auxiliar.txt
EOF
cmd 'cat etapa4_auxiliar.txt'
tela ex12-etapa4-auxiliar
interativo 'man lsblk' ex12-man-lsblk 2
proxima
cmd 'ls -l'
cmd 'cd ..'
transcreve

# --- consolidacao: analise_final.txt, por secoes, com as saidas gravadas em cada etapa
E="$W/ex12_analise"
MAJMIN=$(cat /sys/block/$D/dev)
TAM=$(lsblk -dno SIZE "/dev/$D" | xargs)
FST=$(lsblk -dno FSTYPE "/dev/$D")
VENDOR=$(udevadm info -q property -n "/dev/$D" | sed -n 's/^ID_VENDOR=//p')
MODELO=$(udevadm info -q property -n "/dev/$D" | sed -n 's/^ID_MODEL=//p')
PONTOS=$(findmnt -S "/dev/$D" -no TARGET | xargs | sed 's/ / e /g')
NPART=$(ls -d /sys/block/$D/${D}* 2>/dev/null | wc -l)
recuo() { sed 's/^/    /' "$1"; }
grava analise_final.txt "Exercício 12 — Análise integrada de um dispositivo de armazenamento" 0 <<EOF
DISPOSITIVO ANALISADO: /dev/$D
Escolhido por ser o disco que guarda a raiz (/) do Ubuntu: é o dispositivo de
armazenamento que o sistema realmente usa. Identificado com
    findmnt -no SOURCE /                      -> /dev/$D
    DISCO=\$(basename "\$(findmnt -no SOURCE /)")
A variável DISCO, sempre entre aspas duplas, isola o mesmo dispositivo em todos
os pipelines abaixo (grep -w "\$DISCO", awk -v d="\$DISCO").

================================================================================
1. REPRESENTAÇÃO NO DIRETÓRIO /dev                       (ex12_analise/etapa1_dev.txt)
================================================================================
Comandos executados e finalidade
    ls -l /dev | grep -w "\$DISCO"
        arquivo especial do disco: tipo, dono, grupo e major, minor
    ls -l /dev/disk/by-id /dev/disk/by-uuid | grep -w "\$DISCO"
        nomes persistentes que o udev cria como links para o mesmo disco
    udevadm info -q property -n "/dev/\$DISCO" | grep -E '^(DEVTYPE|ID_...)='
        metadados do udev: tipo, barramento, fabricante, modelo e filesystem
Saída gravada
$(recuo "$E/etapa1_dev.txt")
Principais informações
    - "b" no início das permissões: dispositivo de BLOCO, major,minor $MAJMIN,
      do grupo disk (só root e o grupo disk leem o disco cru).
    - O udev mantém nomes estáveis (by-id pelo identificador SCSI, by-uuid pelo
      UUID do ext4): a letra $D pode mudar entre boots, esses links não.
    - Fabricante $VENDOR, modelo $MODELO, barramento scsi, filesystem $FST.

================================================================================
2. RECONHECIMENTO PELO KERNEL E PARTIÇÕES               (ex12_analise/etapa2_kernel.txt)
================================================================================
Comandos executados e finalidade
    grep -E '^ *8 ' /proc/devices
        driver que o kernel registrou para o major 8
    awk -v d="\$DISCO" 'NR==1 || \$4==d' /proc/partitions
        cabeçalho e a linha do disco na tabela de partições do kernel
    ls -d /sys/block/\$DISCO/\${DISCO}* | wc -l
        conta as partições que o kernel criou no sysfs (sdf1, sdf2...)
    journalctl -k -b --no-pager --no-hostname | grep -w "\$DISCO"
        mensagens do kernel sobre o disco no boot atual
Saída gravada
$(recuo "$E/etapa2_kernel.txt")
Principais informações
    - O major 8 pertence ao driver sd (SCSI disk): o kernel trata o disco
      virtual do Hyper-V (storvsc) como um disco SCSI comum.
    - /proc/partitions traz só a linha de $D, e o sysfs tem $NPART partições: o
      disco não tem tabela de partições. O ext4 ocupa o disco inteiro, como em
      todo disco virtual do WSL. (A hierarquia disco -> partição foi mostrada
      no Ex. 10 com o disco de laboratório.)
    - O log do kernel registra a detecção (tamanho, setores lógicos de 512 e
      físicos de 4096, cache de escrita) e a montagem do ext4.

================================================================================
3. ORGANIZAÇÃO NA HIERARQUIA DE BLOCK DEVICES       (ex12_analise/etapa3_hierarquia.txt)
================================================================================
Comandos executados e finalidade
    lsblk -o NAME,MAJ:MIN,TYPE,SIZE,RO,FSTYPE,MOUNTPOINTS "/dev/\$DISCO"
        o disco na árvore de block devices, com tipo, tamanho e montagem
    findmnt -S "/dev/\$DISCO"
        todos os pontos de montagem que usam esse dispositivo
    readlink -f "/sys/block/\$DISCO"
        posição do disco na árvore de dispositivos do kernel
Saída gravada
$(recuo "$E/etapa3_hierarquia.txt")
Principais informações
    - TYPE disk de $TAM, sem filhos (part) no lsblk: confirma a etapa 2.
    - Um único filesystem, montado em $PONTOS. O segundo é um bind
      mount do subdiretório /mnt/wslg/run/user do mesmo ext4, feito pelo WSLg.
    - No sysfs, o disco fica sob o barramento VMBus do Hyper-V, depois host
      SCSI, alvo e LUN: é a cadeia que o driver percorre até chegar ao bloco.

================================================================================
4. COMANDO AUXILIAR                                     (ex12_analise/etapa4_auxiliar.txt)
================================================================================
Comandos executados e finalidade
    whatis lsblk findmnt udevadm     descrição de uma linha, do índice do man
    type lsblk findmnt               onde está cada comando (/usr/bin)
    lsblk --help | grep ...          opções usadas e úteis (-o, -d, -s)
    man lsblk                        manual completo (Figura no relatório)
Saída gravada
$(recuo "$E/etapa4_auxiliar.txt")

================================================================================
5. CONCLUSÃO
================================================================================
/dev/$D é um disco SCSI virtual ($VENDOR $MODELO) de $TAM, gravável, sem
partições, formatado inteiro em $FST e montado como a raiz do Ubuntu. O kernel
o reconhece pelo driver sd (major 8), o udev cria o arquivo /dev/$D e os nomes
persistentes, o sysfs expõe seus atributos e o lsblk o organiza na hierarquia
de block devices. Cada etapa foi gravada num arquivo próprio com > e reunida
aqui por seções.
EOF

interativo 'less analise_final.txt' ex12-less-analise-final 1.5 34

# =================================================================== organizacao dos artefatos
inicio
cmd '# Organização final dos artefatos do TP2'
cmd 'cd ~/DR2_TP2 && find . -type f | sort'
tela organizacao-artefatos

"${T[@]}" kill-server
# Desassocia o loop do Ex. 10. A imagem (256 MiB, esparsa) fica em ~/DR2_TP2 e nao vai para a copia.
solta_lab
(cd "$W" && tar --exclude='*.img' -cf - .) | (cd "$COPIA" && tar -xf -)
echo "telas capturadas: $FIG"
wc -l "$W"/*.txt "$W"/ex12_analise/*.txt
