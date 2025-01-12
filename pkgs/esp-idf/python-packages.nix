# Versions based on
# https://dl.espressif.com/dl/esp-idf/espidf.constraints.v5.1.txt
# on 2023-07-05.

{ stdenv
, lib
, fetchPypi
, fetchFromGitHub
, pythonPackages
}:

with pythonPackages;

rec {
  idf-component-manager = buildPythonPackage rec {
    pname = "idf-component-manager";
    version = "1.3.2";

    src = fetchFromGitHub {
      owner = "espressif";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-rHZHlvRKMZvvjf3S+nU2lCDXt0Ll4Ek04rdhtfIQ1R0=";
    };

    # For some reason, this 404s.
    /*
      src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-12ozmQ4Eb5zL4rtNHSFjEynfObUkYlid1PgMDVmRkwY=";
      };
    */

    doCheck = false;

    propagatedBuildInputs = [
      cachecontrol
      cffi
      click
      colorama
      packaging
      pyyaml
      requests
      requests-file
      requests-toolbelt
      schema
      six
      tqdm
    ] ++ cachecontrol.optional-dependencies.filecache;

    # setup.py says it needs these deps, but it actually doesn't. contextlib2
    # isn't supported on some pythons and urllib3 is pinned to an old version
    postPatch = ''
      sed -i '/contextlib2/d' setup.py
      sed -i '/urllib3/d' setup.py
    '';

    meta = {
      homepage = "https://github.com/espressif/idf-component-manager";
    };
  };

  esp-coredump = buildPythonPackage rec {
    pname = "esp-coredump";
    version = "1.5.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-hQkXnGoAXCLk/PV7Y+C0hOgXGRY77zbIp2ZDC0cxfLo=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      construct
      pygdbmi
      esptool
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-coredump";
    };
  };

  esptool = buildPythonPackage rec {
    pname = "esptool";
    version = "4.6.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-VJ75Pu9C7n6UYs5aU8Ft96DHHZGz934Z7BV0mATN8wA=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      bitstring
      cryptography
      ecdsa
      pyserial
      reedsolo
      pyyaml
    ];

    # Replaces esptool.py import with .esptool.py-wrapped
    postInstall = ''
      sed -i "2s|^|\n\
      #fix import esptool patch\n\
      import importlib.util\n\
      import importlib.machinery\n\
      esptool_loader = importlib.machinery.SourceFileLoader(\"esptool\", \"$out/bin/.esptool.py-wrapped\")\n\
      esptool_spec = importlib.util.spec_from_loader(\"esptool\", esptool_loader)\n\
      esptool_module = importlib.util.module_from_spec(esptool_spec)\n\
      esptool_spec.loader.exec_module(esptool_module)\n\
      sys.modules[\"esptool\"] = esptool_module\n\
      #end of fix import esptool patch\n|" $out/bin/esp_rfc2217_server.py
    '';

    meta = {
      homepage = "https://github.com/espressif/esptool";
    };
  };

  esp-idf-kconfig = buildPythonPackage rec {
    pname = "esp-idf-kconfig";
    version = "1.1.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-s8ZXt6cf5w2pZSxQNIs/SODAUvHNgxyQ+onaCa7UbFA=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      kconfiglib
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-kconfig";
    };
  };

  esp-idf-monitor = buildPythonPackage rec {
    pname = "esp-idf-monitor";
    version = "1.1.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-c62X3ZHRShhbAFmuPc/d2keqE9T9SXYIlJTyn32LPaE=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      pyserial
      esp-coredump
      pyelftools
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-monitor";
    };
  };

  esp-idf-size = buildPythonPackage rec {
    pname = "esp-idf-size";
    version = "0.3.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-OzthhzKGjyqDJrmJWs4LMkHz0rAwho+3Pyc2BYFK0EU=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      pyyaml
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-size";
    };
  };

  freertos_gdb = buildPythonPackage rec {
    pname = "freertos-gdb";
    version = "1.0.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-o0ZoTy7OLVnrhSepya+MwaILgJSojs2hfmI86D9C3cs=";
    };

    doCheck = false;

    propagatedBuildInputs = [
    ];

    meta = {
      homepage = "https://github.com/espressif/freertos-gdb";
    };
  };

  esp-idf-panic-decoder = buildPythonPackage rec {
    pname = "esp-idf-panic-decoder";
    version = "0.2.0";

    format = "pyproject";
    
    src = fetchPypi {
      inherit version;
      pname = "esp_idf_panic_decoder";
      sha256 = "sha256-t1pg+L7WWVoVZ7weE/CUdMJsgRQvLEUE/GVeJpt0kKI=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      setuptools
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-panic-decoder";
    };
  };
}

