require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'postfix class' do

  context 'basic setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'postfix': }

    	class { 'postfix::vmail': }

    	postfix::transport { 'csc.com':
    		#nexthop => '1.1.1.1',
    		error => 'email to this domain is not allowed',
    	}

    	postfix::vmail::alias { 'caca@caca.com':
    		aliasto => [ 'caca@merda.com' ],
    	}

    	postfix::vmail::account { 'caca@merda.com':
    		accountname => 'caca',
    		domain => 'merda.com',
    		password => 'putamerda',
    	}

    	postfix::vmail::account { 'merda@merda.com':
    		accountname => 'merda',
    		domain => 'merda.com',
    		password => 'putamerda',
    	}

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    it "sleep 10 to make sure postfix is started" do
      expect(shell("sleep 10").exit_code).to be_zero
    end

    describe port(25) do
      it { should be_listening }
    end

    describe package($packagename) do
      it { is_expected.to be_installed }
    end

    describe service($servicename) do
      it { should be_enabled }
      it { is_expected.to be_running }
    end

    # it "send test mail" do
    #   expect(shell("echo \"Testing rspec puppet DUI\" | mail root").exit_code).to be_zero
    # end
    #
    # it "sleep 10 to make sure mesage is delivered" do
    #   expect(shell("sleep 10").exit_code).to be_zero
    # end
    #
    # it "check mail reception" do
    #   expect(shell("grep \"Testing rspec puppet DUI\" /tmp/root").exit_code).to be_zero
    # end

  end

end
