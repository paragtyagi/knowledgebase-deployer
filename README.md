## Knowledgebase - [Deployment]:

We are automating infrastucture deployments using Terraform. We are using Terraform AWS provider to provision AWS infrastructure - creating EC2 instances for hosting Postgresql database and running our Knowledgebase application. In a nutshell, this repository comprises of following AWS resources creation using Terraform -
1. AWS EC2 instances.
2. AWS Security Groups. 
3. AWS ELB.
3. Hosting Postgresql database using user data on one EC2 machine.
5. Setting up Django project using user data on the other EC2 machines.

## Tech stack:
1. Terraform
2. AWS
3. Django
4. Postgres

**Setup Terraform (manual installation):**
1. To install Terraform, find the appropriate package (https://www.terraform.io/downloads.html) for your system and download it. Terraform is packaged as a zip archive.
2. After downloading Terraform, unzip the package. Terraform runs as a single binary named `terraform`.
3. In case of linux, you can directly copy the binary of `terraform` to the `bin` folder, 
	`sudo mv terraform /usr/local/bin`
4. Verify the installation by checking whether Terraform is available,
	```bash
	$ terraform
	Usage: terraform [--version] [--help] <command> [args]

	The available commands for execution are listed below.
	The most common, useful commands are shown first, followed by
	less common or more advanced commands. If you're just getting
	started with Terraform, stick with the common commands. For the
	other commands, please read the help and docs before usage.

	Common commands:
		apply              Builds or changes infrastructure
		console            Interactive console for Terraform interpolations
	# ...
	```
5. Some terraform helpful commands -
	```bash
	terraform apply 	Builds or changes infrastructure
	terraform console	Interactive console for Terraform interpolations
	terraform destroy	Destroy Terraform-managed infrastructure
	terraform fmt	Rewrites config files to canonical format
	terraform init	Initialize a Terraform working directory
	terraform plan	Generate and show an execution plan
	```
Find more using the `help` command - `terraform --help`.

**Setup project:**
1. `git clone` the repository.
2. run command `terraform init`.
3. enviroment variables (you can use [either approach](https://www.terraform.io/docs/configuration/variables.html#environment-variables "either approach")) -
	- aws_access_key
	- aws_secret_key
	- region
	- ami
	- instance_type
	- tag_environment
	- tag_db_name
	- tag_owner
	- tag_project
	- postgresql_version
	- postgres_user
	- postgres_database
	- postgres_password
	- private_key
4. check enviroment variables preferences [here](https://www.terraform.io/docs/configuration/variables.html#variable-definition-precedence "here").

## Some Terraform troubleshooting -

1. If you are trying to copy a file to a directory whose creation is a part of your user data script, the `Terraform apply` will throw a `No such file or directory` error. If you still want to copy a file in such a directory, copy the file in `/tmp` directory and then write a command below the directory creation in the user data to move the file.

2. Use similar approach in case of `Upload failed: scp: /etc/<some_dir>: Permission denied`. Copy first to `/tmp` then use `sudo mv /tmp/<file> /etc/<some_dir>` command in user data ([refer](https://github.com/hashicorp/terraform/issues/8238 "refer")).

3. If something goes wrong with your user data script, refer to the `/var/log/cloud-init-output.log` log file ([refer](https://cloudinit.readthedocs.io/en/latest/index.html "refer")).

4. `null_resource` - If you need to run provisioners that aren't directly associated with a specific resource, you can associate them with a `null_resource` ([refer](https://www.terraform.io/docs/provisioners/null_resource.html "refer")).

5. Ever encountered with a `Error: Could not satisfy plugin requirements` or `Error: provider.<xxx>: no suitable version installed`, try running `terraform init` ([refer](https://github.com/hashicorp/terraform/issues/16127#issuecomment-393537486 "refer")).

6. By defaut `sudo` runs user data as `root` user,
```bash
  sudo echo 'export XXX="something" >> ~/.bashrc'
```
this won't append this file -> `/home/ubuntu/.bashrc`
instead will create a new file -> `/root/.bashrc`
because the user data run by the `root` user privilege.
hence you need specific the actual path like, `sudo echo 'export XXX="something" >> /home/ubuntu/.bashrc'`.
or you need to switch user (`su`) to `ubuntu` just like below.
```bash
sudo su ubuntu -c "$(cat << EOF
    echo 'export XXX="something" >> ~/.bashrc'
EOF
)"
```


## Basic Bash troubleshooting -

1. Basics -
```bash
echo Hello world! # => Hello world!
echo 'This is the first line'; echo 'This is the second line'
Variable="Some string"
Variable = "Some string" # => returns error "Variable: command not found"
Variable= 'Some string' # => returns error: "Some string: command not found"
echo $Variable # => Some string
echo "$Variable" # => Some string
echo '$Variable' # => $Variable
# When you use the variable itself — assign it, export it, or else — you write
# its name without $. If you want to use the variable's value, you should use $.
# Note that ' (single quote) won't expand the variables!
echo ${Variable} # => Some string
```

2. Variable escaping. Two different scenarios -
```bash
sudo su ubuntu -c "$(cat << EOF
    export PATH="/abc:$PATH"
    echo $PATH
    export PATH="/xyz:$PATH"
    echo $PATH
EOF
)"
```
prints,
```bash
 /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
   /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
```
Whats happening? Why `echo $PATH` is not echo-ing the updated value?
As per the snippet above, whatever command inside `$(<command>)` will be executed at one instant. The bash will compile these commands and execute. The compiled command would be,
```bash
  export PATH="/abc:/usr/bin:/us/local/bin"
  echo "/usr/bin:/us/local/bin"
  export PATH="/xyz:/usr/bin:/us/local/bin"
  echo "/usr/bin:/us/local/bin"
```
So why line 2 didn't echoed the overriden value of $PATH? Because the value of $PATH is already evaluated at the time of compilation (since it wasn't **escaped**). On the contrary check the below version,
```bash
sudo su ubuntu -c "$(cat << EOF 
    export PATH="/abc:\$PATH"
    echo \$PATH
    export PATH="/xyz:\$PATH"
    echo \$PATH
EOF
)"
```
prints,
```bash
 /abc:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games 
 /xyz:/abc:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
```
Here the compiled command would be,
```bash
  export PATH="/abc:$PATH"
  echo $PATH
  export PATH="/xyz:$PATH"
  echo $PATH
```
The line 2 and infact the line 4 as well is echo-ing the overriden value everytime. This is because we have escaped the `$PATH` variable at the time of compilation.

3. Scope in bash scripting:
```bash
  export PATH="/home/ubuntu/.pyenv/bin:$PATH"
  curl -L https://pyenv.run | bash
  eval "$(pyenv init -)"
```
The above bash snippet will throw a `pyenv: command not found (on line 3)` exception. Meaning, pyenv was not added in the `PATH`. But we just did in the very first line. So basically each command in a bash script (user data is also a bash script ran by `root` user) runs individually, you can say in its own scope. Mostly faced in case where we want to add environment variable and use later in the same bash script. The above snippet might work if you run it in on bash command line.
When you run `export XXX="something"` this basically adds the variable `XXX` in the environment. If you reloads the bash (or basically closes and opens again, a new bash process), the variable `XXX` won't be present. This is because `export ...` adds the variable in the environment for that instance (for that bash process).
Easy way to test this,
```bash
  export XXX="somthing"
  printenv > /tmp/env.txt
```
If you run this on bash command line, you be able to find the newly created env variable in the env.txt file. But in case of bash script, the new variable won't be present in the file. For making it permanently available you need to add the variable in,
`~/.bashrc or ~/.zshrc or /etc/profile or /etc/environment`.
Cool, but our problem here is not resolved.
Here, we want to add the variable in the environment as well as using the same in the **SAME** bash process. You can achieve this using the below approach (running inside one scope / same bash process).
```bash
sudo su ubuntu -c "$(cat << EOF
    export PATH="/home/ubuntu/.pyenv/bin:$PATH"
    curl -L https://pyenv.run | bash
    eval "$(pyenv init -)"
EOF
)"
```
