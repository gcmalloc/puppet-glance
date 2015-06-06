#!/usr/bin/env ruby
# encoding: utf-8

require 'spec_helper'

require 'puppet/provider/glance_image/glance'
require 'puppet/type/glance_image'

provider_class = Puppet::Type.type(:glance_image).provider(:glance)

describe provider_class do

    describe 'when validating attributes' do
	valid_image_attributes = {:name => 'cloudimg', :ensure => 'present', :source => 'http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img'}
	describe 'when giving neither a location nor a source' do
	     it 'should throw an error' do 
		     resource = Puppet::Type::Glance_image.new({:name => 'cloudimg',
							  :ensure => 'present'})
		     provider = provider_class.new(resource)
		    expect{
			provider.create
		    }.to raise_error(Puppet::Error, "Must specify either source or location")
	     end
	end

	describe 'when giving a disk size' do 
	    min_disk = 5
		 resource = Puppet::Type::Glance_image.new(valid_image_attributes)
		 provider = provider_class.new(resource)
	    it 'should include the disk size in' do
		provider.expects(:auth_glance).with("--min-disk=#{min_disk}")
		provider.create
	    end
	end

	describe 'when giving a memory	size' do 
	    min_ram = 5
		 resource = Puppet::Type::Glance_image.new(valid_image_attributes.merge!(min_ram: min_ram))
		 provider = provider_class.new(resource)
	    it 'should include the memory size in' do
		    provider.create.expects(:auth_glance).with(includes("--min-ram=#{min_ram}"))
		    provider.create
	    end
	end
    end

    describe 'when updating attributes' do
	describe 'for disk size' do
	    min_disk = 5
	    it 'should update the disk size' do
		    provider.expects(:auth_glance).contains("image-update", "--min-disk=#{min_disk}")
	    end
	end
	describe 'for ram size' do
	    min_ram = 5
	    it 'should update the ram size' do
		    provider.expects(:auth_glance).with("image-update", "--min-ram=#{min_ram}")
	    end
	end
    end
end
