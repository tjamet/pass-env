# pass-env
These scripts allows associating environment variables stored in
[pass](https://www.passwordstore.org/) password manager.

# Usage

Clone this repository `git clone https://github.com/tjamet/pass-env.git ~/pass-env`
In your bashrc, add the following lines:
```
. ~/pass-env/bashrc
export PATH=$PATH:~/pass-env/bin
```

Then in any new shell, you will be able to register new environment variable with `pass-env set AWS_ACCESS_KEY my/aws/access_key`
and export it with `penv export`


