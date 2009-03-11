## -------------------------------------------------------------------
##
## Erlang Toolbox: Recursive task definitions
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

verbose false

DIRS = FileList.new

def recurse(task_name)
  DIRS.each do |dir|
    puts "===> Building #{dir}"
    sh "(cd #{dir} && rake --silent #{task_name})"
  end
end

def recursive_task(target)
  task_name = target.kind_of?(Hash) ? target.keys.first : target

  desc "Run #{task_name} in subdirs"
  task target do
    recurse task_name
  end
end
