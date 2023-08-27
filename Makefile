.PHONY: vim pyenv

apt-update:
	sudo apt update

vim: apt-update
	git submodule update --init --recursive neovim
# https://github.com/neovim/neovim/wiki/Building-Neovim#quick-start
	sudo apt install -y --no-install-recommends \
		ninja-build \
		gettext \
		libtool \
		libtool-bin \
		cmake \
		g++ \
		pkg-config \
		unzip \
		curl \
		doxygen
	cd neovim && make CMAKE_BUILD_TYPE=Release
	cd neovim && sudo make install

python: VERSION = 3.11.3
python:
	git submodule update --init --recursive pyenv-installer
# https://devguide.python.org/getting-started/setup-building/#linux
	sudo apt install -y --no-install-recommends \
		build-essential \
		gdb \
		lcov \
		pkg-config \
		libbz2-dev \
		libffi-dev \
		libgdbm-dev \
		libgdbm-compat-dev \
		liblzma-dev \
		libncurses5-dev \
		libreadline6-dev \
		libsqlite3-dev \
		libssl-dev \
		lzma \
		lzma-dev \
		tk-dev \
		uuid-dev \
		zlib1g-dev

# https://github.com/pyenv/pyenv#basic-github-checkout
	bash ./pyenv-installer/bin/pyenv-installer

	@eval "$$(pyenv init - --no-rehash bash)" && \
	pyenv install $(VERSION) && \
	pyenv global $(VERSION) && \
	pip install --upgrade pip && \
	pip install ipython pipenv

node: N_PREFIX ?= ~/.n
node:
	git submodule update --init --recursive n
	mkdir -p ~/.local/bin
	cp n/bin/n ~/.local/bin/n
	N_PREFIX="$(N_PREFIX)" n lts -y
	npm install --ignore-scripts -g pnpm@latest

rust: COMMIT = 17db695f1111fb78f9c0d1b83da0b34723fdf04d
rust:
	curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/rust-lang/rustup/$(COMMIT)/rustup-init.sh | sh -s -- -y --verbose

dots:
	stow home

cli: apt-update
	sudo apt install --no-install-recommends -y \
		curl \
		stow \
		xclip \
		bat \
		ripgrep

desktop-apps: apt-update
	sudo apt install -y \
		gimp \
		inkscape \
		vlc \
		qemu-kvm \
		virt-manager \
		rofi
	sudo usermod -aG libvirt $$USER

docker: apt-update
# sudo apt remove docker docker-engine docker.io containerd runc
# uidmap is required for rootless docker
	sudo apt install -y \
		ca-certificates \
		curl \
		gnupg \
		lsb-release \
		uidmap
	sudo mkdir -m 0755 -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
	sudo apt update
	sudo apt install -y \
		docker-ce \
		docker-ce-cli \
		containerd.io \
		docker-buildx-plugin \
		docker-compose-plugin
	sudo systemctl disable --now docker.service docker.socket
	/usr/bin/dockerd-rootless-setuptool.sh install
	systemctl --user start docker
	systemctl --user enable docker

kubectl: VERSION = v1.26.3
kubectl:
# $(eval version := $(shell curl -Ls https://dl.k8s.io/release/stable.txt))
	curl -LO "https://dl.k8s.io/release/$(VERSION)/bin/linux/amd64/kubectl"
# curl -LO "https://dl.k8s.io/$(version)/bin/linux/amd64/kubectl.sha256"
# echo "$$(cat kubectl.sha256)  kubectl" | sha256sum --check
	echo "026c8412d373064ab0359ed0d1a25c975e9ce803a093d76c8b30c5996ad73e75  kubectl" | sha256sum --check
	chmod +x kubectl
	mkdir -p ~/.local/bin
	mv ./kubectl ~/.local/bin/kubectl
# rm kubectl.sha256

aws: apt-update
	git submodule update --init --recursive aws-cli
	cd aws-cli && \
	./configure --prefix=$$HOME/.local --with-download-deps --with-install-type=portable-exe && \
	make && \
	make install

k9s: VERSION = v0.27.3
k9s:
	curl -L "https://github.com/derailed/k9s/releases/download/$(VERSION)/k9s_Linux_amd64.tar.gz" -o k9s.tar.gz
	echo "b0eb5fb0decedbee5b6bd415f72af8ce6135ffb8128f9709bc7adcd5cbfa690b  k9s.tar.gz" | sha256sum --check
	$(eval tmp := $(shell mktemp -d))
	tar -xvf k9s.tar.gz -C $(tmp)
	mv "$(tmp)/k9s" ~/.local/bin/k9s
	rm -rf k9s.tar.gz $(tmp)

wezterm: VERSION = 20230408-112425-69ae8472
wezterm:
	curl -LO https://github.com/wez/wezterm/releases/download/$(VERSION)/wezterm-$(VERSION).Ubuntu22.04.deb
	echo "058937d36f3d5a68d7169866316280ed2035407f21fb3c5796e337b81876f2bd wezterm-$(VERSION).Ubuntu22.04.deb" | sha256sum --check
	sudo apt install -y ./wezterm-$(VERSION).Ubuntu22.04.deb
	rm wezterm-$(VERSION).Ubuntu22.04.deb

fonts:
	mkdir -p ~/.local/share/fonts

	curl -L https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip -o /tmp/JetBrainsMono.zip
	unzip /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono
	cp /tmp/JetBrainsMono/fonts/ttf/*.ttf ~/.local/share/fonts

	curl -L https://github.com/rsms/inter/releases/download/v3.19/Inter-3.19.zip -o /tmp/Inter.zip
	unzip /tmp/Inter.zip -d /tmp/Inter
	cp /tmp/Inter/Inter\ Desktop/*.otf ~/.local/share/fonts

	curl -L https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip -o /tmp/CascadiaCode.zip
	unzip /tmp/CascadiaCode.zip -d /tmp/CascadiaCode
	cp /tmp/CascadiaCode/ttf/*.ttf ~/.local/share/fonts

	fc-cache -f -v

gh-cli:
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	sudo apt update
	sudo apt install gh -y

gh-desktop: VERSION = 3.2.9
gh-desktop: FILE = GitHubDesktop-linux-amd64-$(VERSION)-linux1.deb
gh-desktop:
	curl -LO https://github.com/shiftkey/desktop/releases/download/release-$(VERSION)-linux1/$(FILE)
	echo "1a8de33e1ebc10e4bcecadbbde6c782e543d184e0749a40e3a350113d3205380  $(FILE)" | sha256sum --check
	sudo apt install -y ./$(FILE)
	rm $(FILE)

fzf: VERSION = 0.39.0
fzf:
	if [ -x ~/.local/bin/fzf ]; then echo "fzf already installed"; false; fi
	curl -LO https://github.com/junegunn/fzf/releases/download/$(VERSION)/fzf-$(VERSION)-linux_amd64.tar.gz
	echo "933ab7849a1b37f491573a48c1674676258f828bd744f4a73229056b26cb21d0 fzf-$(VERSION)-linux_amd64.tar.gz" | sha256sum --check
	tar -xzf fzf-$(VERSION)-linux_amd64.tar.gz
	mv fzf ~/.local/bin/fzf
	rm fzf-$(VERSION)-linux_amd64.tar.gz

jq: VERSION = 1.6
jq:
	if [ -x ~/.local/bin/jq ]; then echo "jq already installed"; false; fi
	curl -LO https://github.com/stedolan/jq/releases/download/jq-$(VERSION)/jq-linux64
	echo "af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44 jq-linux64" | sha256sum --check
	chmod +x jq-linux64
	mv jq-linux64 ~/.local/bin/jq

postman:
	curl -L "https://dl.pstmn.io/download/latest/linux64" -o postman.tar.gz
	$(eval tmp := $(shell mktemp -d))
	tar -xvzf postman.tar.gz -C $(tmp)
	sudo mkdir -p /opt/postman
	sudo mv $(tmp)/Postman/* /opt/postman
	ln -s /opt/postman/Postman ~/.local/bin/postman
	rm postman.tar.gz

.PHONY: systemd-units
systemd-units: UNITS = $(wildcard systemd-units/*.service)
systemd-units:
	sudo cp $(UNITS) /etc/systemd/system
	chmod 744 systemd-units/*.service.sh
	sudo chmod 644 $(subst systemd-units/,/etc/systemd/system/,$(UNITS))
	sudo systemctl daemon-reload
	sudo systemctl enable $(subst systemd-units/,,$(UNITS))

brave:
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
	sudo apt update
	sudo apt install -y brave-browser

obs:
	sudo add-apt-repository ppa:obsproject/obs-studio -y
	sudo apt install -y \
		ffmpeg \
		obs-studio
