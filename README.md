# Breakcorn Radio Gnome Extension

Listen to free internet radio in your Gnome desktop

## Install prerequisites ()

## 

```bash
git clone 'http://github.com/breakcorn/breakcorn-radio-gnome-shell-extension' && cd ./breakcorn-radio-gnome-shell-extension # Clone the repository and change the directory
cp -r 'Breakcorn-Radio@breakcorny@gmail.com' ~/.local/share/gnome-shell/extensions/ # Copy the extension to the user directory
cd .. && rm -rf ./breakcorn-radio-gnome-shell-extension # Remove the repository (optianally)
gnome-extensions enable Breakcorn-Radio@breakcorny@gmail.com && gnome-shell --replace # Or restart gnome-shell by pressing Alt+F2 then type r and press enter then enable it in gnome-tweak-tools.
```

## Uninstall

```bash
rm -rf ~/.local/share/gnome-shell/extensions/Breakcorn-Radio@breakcorny@gmail.com
rm -rf ~/.breakcorn-radio
gnome-shell --replace
```

## License

This program is free software, under GNU General Public License version 3, for more information see LICENSE.
