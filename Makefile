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
