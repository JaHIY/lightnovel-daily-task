# lightnovel-daily-task

## Method 1
rename `config.example` to `config` and set `your username` and `your password` in it, and then you just run:
``` bash
$ main.sh
```

## Method 2
In this way, the script will not load `config` file.
``` bash
$ main.sh 'your_username' 'your_password'
```