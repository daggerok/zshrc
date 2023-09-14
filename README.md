# zshrc
My ~/.zshrc config

```bash
# just in case backup current local .zshrc config
mv -fv $HOME/.zshrc $HOME/.zshrc-$(date +%Y-%m-%d)-backup
# install new .zshrc file
curl -sS https://raw.githubusercontent.com/daggerok/zshrc/main/.zshrc >> $HOME/.zshrc
```
