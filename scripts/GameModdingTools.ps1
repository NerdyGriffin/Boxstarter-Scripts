#--- Mods & Cheats
choco install -y cheatengine
choco install -y vortex
choco install -y wemod

# Install python
choco install -y python

# Refresh path
refreshenv

# Update pip
python -m pip install --upgrade pip

# Install BCML (Tool for cemu mods)
pip install bcml
