require 'serverspec'
require 'net/ssh'

set :backend, :ssh

# CircleCI の add_ssh_keys で追加されたキーを SSH エージェント経由で利用
options = Net::SSH::Config.for(ENV['TARGET_HOST'])
options[:user] = 'ec2-user'

set :host,        ENV['TARGET_HOST']
set :ssh_options, options
