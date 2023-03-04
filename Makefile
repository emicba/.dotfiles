.PHONY: vim pyenv

update:
	sudo apt update

submodule:
	git submodule update --init --recursive

vim: update submodule
	# https://github.com/neovim/neovim/wiki/Building-Neovim#quick-start
	sudo apt-get install \
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
	git submodule update --init --recursive
	cd neovim && make CMAKE_BUILD_TYPE=Release
	cd neovim && sudo make install

python: update submodule
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
	pyenv install 3.10.10 && \
	pyenv global 3.10.10 && \
	pip install --upgrade pip && \
	pip install ipython pipenv

node: submodule
	N_PREFIX=~/.n bash ./n/bin/n lts -y
	npm install --ignore-scripts -g pnpm

dots:
	stow home

cli: update
	sudo add-apt-repository ppa:git-core/ppa -y
	sudo apt install --no-install-recommends -y \
		bat \
		git

docker: update
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
	sudo apt install \
		docker-ce \
		docker-ce-cli \
		containerd.io \
		docker-buildx-plugin \
		docker-compose-plugin
	sudo systemctl disable --now docker.service docker.socket
	/usr/bin/dockerd-rootless-setuptool.sh install
	systemctl --user start docker
	systemctl --user enable docker

kubectl:
# $(eval version := $(shell curl -Ls https://dl.k8s.io/release/stable.txt))
	$(eval version := v1.26.1)
	curl -LO "https://dl.k8s.io/release/$(version)/bin/linux/amd64/kubectl"
# curl -LO "https://dl.k8s.io/$(version)/bin/linux/amd64/kubectl.sha256"
# echo "$$(cat kubectl.sha256)  kubectl" | sha256sum --check
	echo "d57be22cfa25f7427cfb538cfc8853d763878f8b36c76ce93830f6f2d67c6e5d  kubectl" | sha256sum --check
	chmod +x kubectl
	mkdir -p ~/.local/bin
	mv ./kubectl ~/.local/bin/kubectl
# rm kubectl.sha256

wezterm:
	curl -LO https://github.com/wez/wezterm/releases/download/20221119-145034-49b9839f/wezterm-20221119-145034-49b9839f.Ubuntu22.04.deb
	sudo apt install -y ./wezterm-20221119-145034-49b9839f.Ubuntu22.04.deb || true
	rm wezterm-20221119-145034-49b9839f.Ubuntu22.04.deb

fonts:
	mkdir -p ~/.local/share/fonts

	curl -L https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip -o /tmp/JetBrainsMono.zip
	unzip /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono
	cp /tmp/JetBrainsMono/fonts/ttf/*.ttf ~/.local/share/fonts

	curl -L https://github.com/rsms/inter/releases/download/v3.19/Inter-3.19.zip -o /tmp/Inter.zip
	unzip /tmp/Inter.zip -d /tmp/Inter
	cp /tmp/Inter/Inter\ Desktop/*.otf ~/.local/share/fonts

	fc-cache -f -v

gh-cli:
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	sudo apt update
	sudo apt install gh -y

gh-desktop:
	curl -LO https://github.com/shiftkey/desktop/releases/download/release-3.1.8-linux1/GitHubDesktop-linux-3.1.8-linux1.deb
	echo "1d8082b74d5ffb94d43270eaaeffaad235f97560153dbf76fba2bb9f4c8f2c90  GitHubDesktop-linux-3.1.8-linux1.deb" | sha256sum --check
	sudo apt install -y ./GitHubDesktop-linux-3.1.8-linux1.deb || true
	rm GitHubDesktop-linux-3.1.8-linux1.deb

fzf:
	if [ -x ~/.local/bin/fzf ]; then echo "fzf already installed"; false; fi
	$(eval version := 0.38.0)
	$(eval binary := fzf-$(version)-linux_amd64.tar.gz)
	curl -LO https://github.com/junegunn/fzf/releases/download/0.38.0/$(binary)
	echo "6745b1aab975fed7dbdb5813701a39d24591114b237473bed88d3d14ec3d46a5 $(binary)" | sha256sum --check
	tar -xzf $(binary)
	mv fzf ~/.local/bin/fzf
	rm $(binary)

jq:
	if [ -x ~/.local/bin/jq ]; then echo "jq already installed"; false; fi
	curl -LO https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
	echo "af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44 jq-linux64" | sha256sum --check
	chmod +x jq-linux64f
	mv jq-linux64 ~/.local/bin/jq
