# Fastfetch Setup

## 1. Add alias to `.bashrc`

Add this line to your `~/.bashrc`:

```bash
alias ff='BLUEFIN_FETCH_LOGO=$(find $HOME/.config/fastfetch/logo/* | /usr/bin/shuf -n 1) && /usr/bin/fastfetch --logo $BLUEFIN_FETCH_LOGO -c $HOME/.config/fastfetch/config.jsonc'
```

Then reload:
```bash
source ~/.bashrc
```

## 2. Create config directory

```bash
mkdir -p $HOME/.config/fastfetch
```

## 3. Copy config files

Copy your config and logo files to:

```bash
cp config.jsonc $HOME/.config/fastfetch/
cp -r logos $HOME/.config/fastfetch/
```

## 4. Customize (optional)

Edit the config file to suit your preferences:

```bash
nano $HOME/.config/fastfetch/config.jsonc
```

## 5. Run

```bash
ff
```
