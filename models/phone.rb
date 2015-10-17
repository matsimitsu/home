require 'arp_scan'

class Phone < ActiveRecord::Base
  def self.active?
    self.where("last_seen_at > ?", 10.minutes.ago.utc).any?require './app';
  end

  def self.update_seen
    report = ARPScan('--localnet')
    report.hosts.each do |host|
      if phone = Phone.find_by(:mac => host.mac)
        phone.touch(:last_seen_at)
      end
    end
  end

end
