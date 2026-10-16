@echo off
rem Resolve the exposed symlink before locating this checkout, preserving arguments.
python -S -c "import os,runpy,sys;from pathlib import Path;root=Path(sys.argv[1]).resolve().parent;engine=root/'vendor'/'etch'/'etch';sys.argv=[str(engine)]+(sys.argv[2:] or ['plan','--profile','developer']);os.chdir(root);sys.path.insert(0,str(engine.parent));runpy.run_path(str(engine),run_name='__main__')" "%~f0" %*
exit /b %errorlevel%
