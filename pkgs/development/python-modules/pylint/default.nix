{ stdenv, buildPythonPackage, fetchPypi, python, astroid, isort,
  pytest, pytestrunner,  mccabe, configparser, backports_functools_lru_cache }:

buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "pylint";
  version = "1.8.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "c77311859e0c2d7932095f30d2b1bfdc4b6fe111f534450ba727a52eae330ef2";
  };

  buildInputs = [ pytest pytestrunner mccabe configparser backports_functools_lru_cache ];

  propagatedBuildInputs = [ astroid configparser isort mccabe ];

  postPatch = ''
    # Remove broken darwin tests
    sed -i -e '/test_parallel_execution/,+2d' pylint/test/test_self.py
    sed -i -e '/test_py3k_jobs_option/,+4d' pylint/test/test_self.py
    rm -vf pylint/test/test_functional.py
  '';

  checkPhase = ''
    cd pylint/test
    ${python.interpreter} -m unittest discover -p "*test*"
  '';

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp
    cp "elisp/"*.el $out/share/emacs/site-lisp/
  '';

  meta = with stdenv.lib; {
    homepage = http://www.logilab.org/project/pylint;
    description = "A bug and style checker for Python";
    platforms = platforms.all;
    license = licenses.gpl1Plus;
    maintainers = with maintainers; [ nand0p ];
  };
}
