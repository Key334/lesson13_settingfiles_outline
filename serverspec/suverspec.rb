require 'spec_helper'

# ----------------------------------------------------------------
# 変数定義
# ----------------------------------------------------------------
http_port       = 80
redis_port      = 6379
ruby_version    = '3.2.3'
app_dir         = '/home/ec2-user/raisetech-live8-sample-app'
app_user        = 'ec2-user'

# ================================================================
# パッケージ
# ================================================================
describe package('nginx') do
  it { should be_installed }
end

describe package('redis') do
  it { should be_installed }
end

describe package('nodejs') do
  it { should be_installed }
end

describe package('mysql-community-client') do
  it { should be_installed }
end

# ================================================================
# サービス
# ================================================================
describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

describe service('redis') do
  it { should be_enabled }
  it { should be_running }
end

describe service('puma') do
  it { should be_enabled }
  it { should be_running }
end

# ================================================================
# ポート
# ================================================================
describe port(http_port) do
  it { should be_listening }
end

describe port(redis_port) do
  it { should be_listening }
end

# ================================================================
# プロセス
# ================================================================
describe process('nginx') do
  it { should be_running }
end

describe process('redis-server') do
  it { should be_running }
end

describe process('puma') do
  it { should be_running }
end

# ================================================================
# ユーザー
# ================================================================
describe user('www-data') do
  it { should exist }
end

describe user(app_user) do
  it { should exist }
end

# ================================================================
# Ruby / rbenv
# ================================================================
describe command("sudo -u #{app_user} /home/#{app_user}/.rbenv/bin/rbenv version") do
  its(:stdout) { should match /#{Regexp.escape(ruby_version)}/ }
  its(:exit_status) { should eq 0 }
end

describe command("sudo -u #{app_user} /home/#{app_user}/.rbenv/shims/ruby -v") do
  its(:stdout) { should match /#{Regexp.escape(ruby_version)}/ }
  its(:exit_status) { should eq 0 }
end

describe command("sudo -u #{app_user} /home/#{app_user}/.rbenv/shims/bundle -v") do
  its(:exit_status) { should eq 0 }
end

# ================================================================
# Node.js / Yarn
# ================================================================
describe command('node -v') do
  its(:stdout) { should match /^v18\./ }
  its(:exit_status) { should eq 0 }
end

describe command('yarn -v') do
  its(:exit_status) { should eq 0 }
end

# ================================================================
# Nginx 設定ファイル
# ================================================================
describe file('/etc/nginx/nginx.conf') do
  it { should be_file }
  it { should be_readable }
end

describe file('/etc/nginx/conf.d/app.conf') do
  it { should be_file }
  it { should be_readable }
  its(:content) { should match /upstream puma/ }
  its(:content) { should match /listen 80/ }
  its(:content) { should match /#{Regexp.escape(app_dir)}/ }
end

# ================================================================
# アプリケーションディレクトリ・ファイル
# ================================================================
describe file(app_dir) do
  it { should be_directory }
  it { should be_owned_by app_user }
end

describe file("#{app_dir}/config/database.yml") do
  it { should be_file }
  it { should be_owned_by app_user }
  it { should be_mode 640 }
end


describe file("#{app_dir}/tmp/sockets/puma.sock") do
  it { should be_socket }
end

describe file("#{app_dir}/public/assets") do
  it { should be_directory }
end

# ================================================================
# HTTP レスポンス確認
# ================================================================
describe command("curl -o /dev/null -s -w \"%{http_code}\" http://127.0.0.1:#{http_port}/") do
  its(:stdout) { should match /^200$/ }
end
