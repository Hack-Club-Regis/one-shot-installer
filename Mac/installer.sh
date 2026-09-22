# colores colores
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
ENDCOLOR='\e[0m' 

echo "${GREEN}Hack Club Regis Application Installer version 1.0.3${ENDCOLOR}"
echo "This will install apps like Homebrew, VS Code, GitHub, Anaconda, Node.js, and Hackatime on your PC."
echo "The installation will begin in 10 seconds. Press Ctrl + C NOW to abort."
sleep 10

echo "${YELLOW}Beginning Homebrew installation. Follow the prompts below. Homebrew will explain what it does before it does it, so pay attention!${ENDCOLOR}"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

set -e

# Locate Homebrew
if command -v brew >/dev/null 2>&1; then
    BREW_PATH="$(command -v brew)"
elif [[ -x "/opt/homebrew/bin/brew" ]]; then
    BREW_PATH="/opt/homebrew/bin/brew"
elif [[ -x "/usr/local/bin/brew" ]]; then
    BREW_PATH="/usr/local/bin/brew"
else
    echo "Homebrew is not installed."
    exit 1
fi

# Refresh Homebrew's environment
eval "$("$BREW_PATH" shellenv)"

# Confirm it works
if ! brew --version >/dev/null 2>&1; then
    echo "Homebrew could not be executed."
    exit 1
fi

echo "Homebrew is ready: $(brew --version | head -n 1)"

# VS Code

if [command -v code >/dev/null 2>&1]; then
    echo "${GREEN}VS Code is already installed.${ENDCOLOR}"
    code-version = "standard"
elif [command -v code-insiders >/dev/null 2>&1]; then
    echo "${GREEN}VS Code Insiders is already installed.${ENDCOLOR}"
    code-version = "insiders"
else
    echo "${RED}VS Code not found. Installing VS Code from Brew...${ENDCOLOR}"
    brew install --cask visual-studio-code -q
fi

if command -v code >/dev/null 2>&1; then
    code --version
    echo "${GREEN}VS Code CLI is available.${ENDCOLOR}"
    CODE-READY = 1
elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
    echo "${GREEN}VS Code CLI found and added to PATH.${ENDCOLOR}"
    CODE-READY = 1
else
    echo "${RED}VS Code CLI not found. Extensions will not be installed.${ENDCOLOR}"
    CODE-READY = 0
fi

if CODE-READY == 1; then
    extensions = (
        "ms-python.python"
        "ms-python.vscode-pylance"
        "GitHub.copilot-chat"
        "GitHub.vscode-pull-request-github"
        "ms-vscode.live-server"
        "ms-python.debugpy"
        "ms-python.vscode-python-envs"
        "ms-vscode.remote-server"
        "ms-vscode-remote.remote-ssh-edit"
        "ms-vscode-remote.remote-ssh"
        "ms-vscode.remote-explorer"
        "WakaTime.vscode-wakatime"
    )
    echo "Installing VS Code extensions..."
    if [code-version == "insiders"]; then
        code_command="code-insiders"
    else
        code_command="code"
    fi
    for extension in "${extensions[@]}"; do
        echo "Installing extension: $extension..."
        $code_command --install-extension "$extension"
    done
fi

# Git
if [command -v git >/dev/null 2>&1]; then
    echo "${GREEN}Git is already installed.${ENDCOLOR}"
else
    echo "${RED}Git not found. Installing Git from Brew...${ENDCOLOR}"
    brew install git -q
fi

# Giuthub CLI
if [command -v gh >/dev/null 2>&1]; then
    echo "${GREEN}GitHub CLI is already installed.${ENDCOLOR}"
else
    echo "${RED}GitHub CLI not found. Installing GitHub CLI from Brew...${ENDCOLOR}"
    brew install gh -q
fi

if ! gh auth status 2>/dev/null || {
    echo "${YELLOW}You are not signed in to GitHub. Follow the steps to sign in.${ENDCOLOR}"
    gh auth login --hostname github.com --git-protocol https --web
}
else
    echo "${GREEN}GitHub authentication detected.${ENDCOLOR}"
fi

sleep 5
git clone "https://github.com/Hack-Club-Regis/HOOT-Web-Frontend.git" "$HOME\HOOT\HOOT-Web-Frontend"
git clone "https://github.com/Hack-Club-Regis/HOOT-AI-Backend.git" "$HOME\HOOT\HOOT-AI-Backend"

# GitHub Desktop
if [command -v github >/dev/null 2>&1]; then
    echo "${GREEN}GitHub Desktop is already installed.${ENDCOLOR}"
else
    echo "${RED}GitHub Desktop not found. Installing GitHub Desktop from Brew...${ENDCOLOR}"
    brew install --cask github -q
fi

# Anaconda
if [command -v conda >/dev/null 2>&1]; then
    echo "${GREEN}Anaconda is already installed.${ENDCOLOR}"
else
    echo "${RED}Anaconda not found. Installing Anaconda from Brew...${ENDCOLOR}"
    brew install --cask anaconda -q
fi

sleep 5
TIMEOUT_SECONDS=60
ELAPSED_SECONDS=0

while ! command -v conda >/dev/null 2>&1; do
    if (( ELAPSED_SECONDS >= TIMEOUT_SECONDS )); then
        echo "Timed out waiting for Conda."
        exit 1
    fi

    # Refresh Homebrew environment if available
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Check common Conda installation locations
    for CONDA_PATH in \
        "$HOME/anaconda3/bin" \
        "$HOME/miniconda3/bin" \
        "/opt/anaconda3/bin" \
        "/opt/miniconda3/bin"; do

        if [[ -x "$CONDA_PATH/conda" ]]; then
            export PATH="$CONDA_PATH:$PATH"
            break
        fi
    done

    echo "Waiting for Conda... ($ELAPSED_SECONDS/$TIMEOUT_SECONDS seconds)"
    sleep 1
    ((ELAPSED_SECONDS++))
done

# echo "Conda is available!"
# conda --version

conda create -n HOOT python=3.14 -y
conda activate HOOT
python-packages = (
    "numpy"
)

for python-package in "${python-packages[@]}"; do
        echo "Installing Python package: $python-package..."
        python -m pip install "$python-package"

        if $? -ne 0; then
            echo "${RED}Failed to install $python-package${ENDCOLOR}"
            # exit 1
        else
            echo "${GREEN}$python-package installed successfully.${ENDCOLOR}"        
        fi
done

# Node.js

if [command -v node >/dev/null 2>&1]; then
    echo "${GREEN}Node.js is already installed.${ENDCOLOR}"
else
    echo "${RED}Node.js not found. Installing Node.js from Brew...${ENDCOLOR}"
    brew install node -q
fi

ELAPSED_SECONDS=0

while ! command -v node >/dev/null 2>&1 || ! node --version >/dev/null 2>&1; do
    if (( ELAPSED_SECONDS >= TIMEOUT_SECONDS )); then
        echo "Node.js failed to become available within ${TIMEOUT_SECONDS} seconds."
        exit 1
    fi

    # echo "Waiting for Node.js... (${ELAPSED_SECONDS}/${TIMEOUT_SECONDS} seconds)"
    sleep 1
    ((ELAPSED_SECONDS++))
done

# echo "Node.js is ready: $(node --version)"
# echo "npm version: $(npm --version)"

cd "$HOME/HOOT/HOOT-Web-Frontend"
npm ci

# Hackatime
if [[-d $HOME/.wakatime] || [-d $HOME/wakatime.cfg]]; then
    echo "${GREEN}Hackatime is already installed.${ENDCOLOR}"
else
    echo "${RED}Hackatime not found.${ENDCOLOR}"
    echo "Hackatime is Hack Club's time tracking tool. You'll need this for YSWS. Sign in in your browser, then paste the command it gives you below."
    open "https://hackatime.hackclub.com/setup?step=terminal-command"
    read -p "Paste the command here: " HACKATIME_COMMAND
    eval "$HACKATIME_COMMAND"
fi

echo "${GREEN}Installation complete!${ENDCOLOR}"
echo "                                                                                                
                                                                                                
                                                                                                
                                                                                                
                                 %%%%%%%%%%%%%%#                                                
                               %@%%%%%%%%%%%%%%%%%%%%                                    +%%%   
@@@                            @@%%%%.-%%%%%%%%%%%%%%%%%%%                           #%%%%@%    
.-@@@@                        %@%%%%...%%*..%%%#:%%%%%%%%%%%%%%%               +#%%%%%%%%@%     
....:%@@@                    %@%%%%%.......*%%:...%%%-.-%%%%%%%%%%%@%%%%%%%%%%%%%%#++%%%%@%%%%%%
........=@@@@               %@%%%%%...#=...%%-.%-:%#..%+%#.%%%%%%%%%%%%%%%%%%%%-%--%.%%%%%%%%%% 
............+@%@@@@         @@%%%%%-+%%%..%%.....*%..%%%%-.%*.%%%%%-.+%=+%%%.%%.=%.=%.%%%%@%%   
.................-#@@%%@@  @@%%%%%%%%%%%+%%%.%%..%%.=%%%%....%%%%%::%%%=.%%%--%-.%--#+%%%%#     
.................*@-....#@%@%%%%%%%%%%%%%%%%%%%%%%%..=%%..#..%%%%%.=%%%%.%%%%-=.*%%%%%%#        
................@*.......=@@          %%%%%%%%%%%%%%%%%%-%%=.#%%%%+.+#%%...-#%%%%%%%%+          
...............%*.......=#%%@                %%%%%%%%%%%%%%%%%%%%%%#+*%%%%%%%%%%%%+             
..............=%......@%:...@@                     @%%%%%%%%%%%%%%%%%%%%%%%%%%+                 
..............@.........@@..@@                             +@@@@%%%%%%%%*++                     
.............+*......:=#*@@@@                                                                   
.............@......@*+...@@                                                                    
.............@.......=@@..@@                                                                    
............=#......=@%@@@@                                                                     
............=*....:@*-...@                                                                      
@@=..........@.....:@@#..@                                                                      
  @@@%%=.....*%...=@@@@#@@                                                                      
       @@@@@%%@@%@@                                                                             
                                                                                                
                                                                                                
                                                                                                
                                                                                                
"