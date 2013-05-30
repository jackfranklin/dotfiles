echo "Symlinking all files in ~/dotfiles/bin to /usr/bin"
for file in bin/*
do
  echo "Symlinking $file"
  # file is bin/filename
  # do something on "$file"
  sudo ln -sf ~/dotfiles/$file /usr/$file
done
