require 'spec_helper'
require 'puppet-retrospec'
require 'helpers'

describe "puppet-retrospec" do
  after :all do
    #FileUtils.rm_rf(fixture_modules_path)
  end

  before :each do
    @retro = Retrospec.new(Dir.glob('spec/fixtures/manifests/*.pp'))
  end

  it 'should run without errors' do
    install_module('puppetlabs-tomcat')
    tomcat = Retrospec.new('spec/fixtures/modules/tomcat')
    tomcat.create_files
  end

  it 'manifest path is calculated correctly' do
     @retro.manifest_dir.should eq('spec/fixtures/manifests')
  end

  it 'should return a list of files' do
    @retro.manifest_files.length.should == 3
  end

  it 'should retrieve a list of includes' do
    # ie. {"includes-class"=>["class1", "class2", "class3", "class6"]}
     includes = @retro.included_declarations('spec/fixtures/manifests/includes-class.pp')
     includes['includes-class'].should eq(["class1", "class2", "class3", "class6"])
  end

  it 'should not include the require statements' do
    # ie. {"includes-class"=>["class1", "class2", "class3", "class6"]}
    includes = @retro.included_declarations('spec/fixtures/manifests/includes-class.pp')
    includes['includes-class'].should_not eq(["class1", "class2", "class3", "class4", "class5", "class6"])
  end

  it 'should retrieve a list of class names' do
    # ie. [{:filename=>"includes-class", :types=>[{:type_name=>"class", :name=>"includes-class"}]}]
    classes = @retro.classes_and_defines('spec/fixtures/manifests/includes-class.pp')
    types = classes.first[:types]
    types.first[:type_name].should eq('class')
    types.first[:name].should eq("includes-class")
  end

  it 'should retrieve 0 defines or classes' do
    my_retro = Retrospec.new('spec/fixtures/manifests/not_a_resource_defination.pp')
    classes = my_retro.classes_and_defines('spec/fixtures/manifests/not_a_resource_defination.pp')
    classes.count.should == 0
  end

  it 'should not create any files when 0 resources exists' do
    my_retro = Retrospec.new('spec/fixtures/manifests/not_a_resource_defination.pp')
    my_retro.safe_create_resource_spec_files(my_retro.manifest_files.first)
  end

  it 'should retrieve a list of define names' do
    # ie. [{:filename=>"includes-class", :types=>[{:type_name=>"class", :name=>"includes-class"}]}]
    my_retro = Retrospec.new('spec/fixtures/manifests/includes-defines.pp')
    classes = my_retro.classes_and_defines('spec/fixtures/manifests/includes-defines.pp')
    types = classes.first[:types]
    types.first[:type_name].should eq('define')
    types.first[:name].should eq("webinstance")
  end

  it 'should create proper spec helper file' do
    filepath = File.expand_path(File.join(fixtures_path, 'spec/spec_helper.rb'))
    Helpers.should_receive(:safe_create_file).with(filepath,anything).once
    @retro.safe_create_spec_helper('spec_helper_file.erb')

  end

  it 'should return the correct module name' do
    Helpers.should_receive(:get_module_name).and_return('mymodule')
    @retro.module_name.should eq('mymodule')
  end

  it 'should create proper fixtures file' do
    filepath = File.expand_path(File.join(fixtures_path, '.fixtures.yml'))
    Helpers.should_receive(:safe_create_file).with(filepath,anything).once
    @retro.safe_create_fixtures_file('fixtures_file.erb')

  end

  it 'included_declarations should not be nil' do
    @retro.included_declarations(@retro.manifest_files.first).length.should >= 1
  end

  it 'classes_and_defines should not be nil' do
    @retro.classes_and_defines(@retro.manifest_files.first).length.should >= 1
  end

  it 'module_name should not be nil' do
    Helpers.should_receive(:get_module_name).and_return('mymodule')
    @retro.module_name.should_not be_nil
  end

  it 'modules_included should not be nil' do
    @retro.modules_included.length.should eq(1)
  end

end