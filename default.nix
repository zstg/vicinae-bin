{
  cmake,
  fetchFromGitHub,
  ninja,
  nodejs,
  stdenv,
  lib,
  fetchNpmDeps,
  npmHooks,

  abseil-cpp,
  cmark-gfm,
  libqalculate,
  minizip,
  rapidfuzz-cpp,
  protobuf,
  kdePackages,
  qt6,
  openssl,
}:
let
  _src = fetchFromGitHub {
    owner = "vicinaehq";
    repo = "vicinae";
    tag = "v0.14.2";
    hash = "sha256-LoTp1sPD5c6wBWp1g4yqJwhkLE9liPRA7tSJYRnP8fQ=";
  };
  apiNpmDeps = fetchNpmDeps {
	  name = "vicinae-0.14.2-api-npm-deps";
	  src = "${_src}/typescript/api";
	  hash = "sha256-dSHEzw15lSRRbldl9PljuWFf2htdG+HgSeKPAB88RBg=";
  };
  extension-managerNpmDeps = fetchNpmDeps {
	  name = "vicinae-0.14.2-extension-manager-npm-deps";
	  src = "${_src}/typescript/extension-manager";
	  hash = "sha256-TCT7uZRZn4rsLA/z2yLeK5Bt4DJPmdSC4zkmuCxTtc8=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vicinae";
  version = "0.14.2";

  src = _src; 

  postPatch = ''
	# export npmRoot=./typescript/api
	local postPatchHooks=()
	source ${npmHooks.npmConfigHook}/nix-support/setup-hook
	npmRoot=./typescript/api npmDeps=${apiNpmDeps} npmConfigHook
	npmRoot=./typescript/extension-manager npmDeps=${extension-managerNpmDeps} npmConfigHook
	echo "Done with npm silliness"
  '';

  nativeBuildInputs = [
    # autoPatchelfHook
    cmake
    cmark-gfm
    kdePackages.layer-shell-qt
    kdePackages.qtkeychain
    libqalculate
    minizip
    ninja
    nodejs
    protobuf
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    qt6.wrapQtAppsHook
    rapidfuzz-cpp
  ];
  buildInputs = [
    abseil-cpp
    cmark-gfm
    kdePackages.layer-shell-qt
    kdePackages.qtkeychain
    libqalculate
    minizip
    nodejs
    openssl
    protobuf
    qt6.qt5compat
    qt6.qtdeclarative
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
  ];
  cmakeFlags = with lib.strings; [
  	(cmakeBool "USE_SYSTEM_PROTOBUF" true)
	  (cmakeBool "USE_SYSTEM_ABSEIL" true)
	  (cmakeBool "USE_SYSTEM_CMARK_GFM" true)
	  (cmakeBool "USE_SYSTEM_MINIZIP" true)
  ];

})
