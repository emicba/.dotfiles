.PHONY: vim pyenv zoxide

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
	corepack enable
	npm --version
	yarn --version
	pnpm --version

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

# https://github.com/wez/wezterm/releases/latest
wezterm: VERSION = 20240203-110809-5046fc22
wezterm:
	curl -LO https://github.com/wez/wezterm/releases/download/$(VERSION)/wezterm-$(VERSION).Ubuntu22.04.deb
	echo "86358dab5794a4fb63f7c91dd68d4fdc3da58faad648a58fc77d2bd51c7b0686 wezterm-$(VERSION).Ubuntu22.04.deb" | sha256sum --check
	sudo apt install -y ./wezterm-$(VERSION).Ubuntu22.04.deb
	rm wezterm-$(VERSION).Ubuntu22.04.deb

fonts: GEIST_VERSION = 1.3.0
fonts:
	mkdir -p ~/.local/share/fonts

# https://github.com/JetBrains/JetBrainsMono/releases/latest
	rm -rf /tmp/JetBrainsMono{,.zip}
	curl -fsSL https://download-cdn.jetbrains.com/fonts/JetBrainsMono-2.304.zip -o /tmp/JetBrainsMono.zip
	unzip /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono
	cp -t ~/.local/share/fonts /tmp/JetBrainsMono/fonts/ttf/*.ttf

# https://github.com/rsms/inter/releases/latest
	rm -rf /tmp/Inter{,.zip}
	curl -fsSL https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip -o /tmp/Inter.zip
	unzip /tmp/Inter.zip -d /tmp/Inter
	cp -t ~/.local/share/fonts /tmp/Inter/*.ttf /tmp/Inter/extras/ttf/*.ttf

# https://github.com/microsoft/cascadia-code/releases/latest
	rm -rf /tmp/CascadiaCode{,.zip}
	curl -fsSL https://github.com/microsoft/cascadia-code/releases/download/v2404.23/CascadiaCode-2404.23.zip -o /tmp/CascadiaCode.zip
	unzip /tmp/CascadiaCode.zip -d /tmp/CascadiaCode
	cp -t ~/.local/share/fonts /tmp/CascadiaCode/ttf/*.ttf

# https://github.com/vercel/geist-font/releases/latest
	rm -rf /tmp/GeistMono*{,.zip}
	curl -fsSL https://github.com/vercel/geist-font/releases/download/$(GEIST_VERSION)/GeistMono-$(GEIST_VERSION).zip -o /tmp/GeistMono.zip
	unzip /tmp/GeistMono.zip -d /tmp/GeistMono
	cp -t ~/.local/share/fonts /tmp/GeistMono/GeistMono-$(GEIST_VERSION)/variable-ttf/*.ttf

	fc-cache -f -v

gh-cli:
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	sudo apt update
	sudo apt install -y gh

# https://github.com/shiftkey/desktop/releases/latest
gh-desktop: VERSION = 3.4.2-linux1
gh-desktop: FILE = GitHubDesktop-linux-amd64-$(VERSION).deb
gh-desktop:
	curl -LO https://github.com/shiftkey/desktop/releases/download/release-$(VERSION)/$(FILE)
	echo " a98e6b0af3a07f5fd9d345d9eb2027eb329d519fba9783c2b613d4e385cb2a17  $(FILE)" | sha256sum --check
	sudo apt install -y ./$(FILE)
	rm $(FILE)

# https://github.com/junegunn/fzf/releases/latest
fzf: VERSION = 0.54.3
fzf: FILE = fzf-$(VERSION)-linux_amd64.tar.gz
fzf:
# if [ -x ~/.local/bin/fzf ]; then echo "fzf already installed"; false; fi
	curl -LO https://github.com/junegunn/fzf/releases/download/v$(VERSION)/$(FILE)
	echo "6867008c46307f036e48b42ab9bfdc3224657f6a65d70c58a1f456c4d9348cf6  $(FILE)" | sha256sum --check
	tar -xzf $(FILE)
	mv fzf ~/.local/bin/fzf
	rm $(FILE)
	fzf --version

# https://github.com/jqlang/jq/releases/latest
jq: VERSION = 1.7.1
jq: FILE = jq-linux64
jq:
# if [ -x ~/.local/bin/jq ]; then echo "jq already installed"; false; fi
	curl -LO https://github.com/jqlang/jq/releases/download/jq-$(VERSION)/$(FILE)
	echo "5942c9b0934e510ee61eb3e30273f1b3fe2590df93933a93d7c58b81d19c8ff5  $(FILE)" | sha256sum --check
	chmod +x $(FILE)
	mv $(FILE) ~/.local/bin/jq
	jq --version

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

.PHONY: udev-rules
udev-rules: RULES = $(wildcard udev-rules/*.rules)
udev-rules:
	sudo cp $(RULES) /etc/udev/rules.d/
	sudo udevadm trigger
	sudo udevadm control --reload-rules

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

obsidian: VERSION = 1.3.7
obsidian: FILE = obsidian_$(VERSION)_amd64.deb
obsidian:
	curl -LO https://github.com/obsidianmd/obsidian-releases/releases/download/v$(VERSION)/$(FILE)
	echo "c4795b39933dc4cc1a35a33841f91488fc767f5712731c95f3bbd36e12751894  $(FILE)" | sha256sum --check
	sudo apt install -y ./$(FILE)
	rm $(FILE)

firefox: MOZILLA_FINGERPRINT = 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3
firefox:
	sudo install -d -m 0755 /etc/apt/keyrings
	wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
# gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/^ +| +$/{print $1}'
	@FINGERPRINT=$$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/^ +| +$$/{print $$1}');\
	if [ "$$FINGERPRINT" != "$(MOZILLA_FINGERPRINT)" ]; then \
		echo "FINGERPRINT VERIFICATION FAILED"; \
		false; \
	fi
	echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null
	echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla
	sudo apt update
	sudo apt install -y firefox

firefox-dev:
ifneq (,$(wildcard /opt/firefox-dev))
	@echo "Firefox Developer Edition already installed."
	@false
endif
	$(eval TEMP_DIR := $(shell mktemp -d))
	curl -L "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US" -o $(TEMP_DIR)/firefox.tar.bz2
	tar -xvjf $(TEMP_DIR)/firefox.tar.bz2 -C $(TEMP_DIR)
	sudo mv $(TEMP_DIR)/firefox /opt/firefox-dev
	rm -rf $(TEMP_DIR)
	ln -s /opt/firefox-dev/firefox ~/.local/bin/firefox-dev

bun: VERSION = 1.1.0
bun:
	curl -fsSL https://bun.sh/install | bash

zoxide:
	git submodule update --init --recursive zoxide
	cd zoxide && cargo build --release --locked
	cp zoxide/target/release/zoxide ~/.local/bin/zoxide
	mkdir -p ~/.local/share/man/man1/
	cp zoxide/man/man1/* ~/.local/share/man/man1/
