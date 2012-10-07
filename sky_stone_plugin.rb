require 'singleton'
$:.unshift(File.expand_path(File.dirname(__FILE__))) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require_relative 'SkyStone/plugin'
require_relative 'SkyStone/storage_cart_system'
require_relative 'SkyStone/carts_router'
require_relative 'SkyStone/carts_terminal'

class SkyStonePlugin
  include Purugin::Plugin, Purugin::Colors
  description 'SkyStone', 0.1

  def on_enable
    force_reload!

    @plugin = SkyStone::Plugin.instance
    @plugin.setup self
    @plugin.broadcast "Loaded 'SkyStone' plugin"

    public_player_command('skystone', 'Skystone', "/skystone ...") do |me, *args|
      cmd(me, args)
    end

    # Somehow I need this self or my server chokes - Plugin.instance doesn't do the trick
    @storage_cart_system = SkyStone::StorageCartSystem.new(self)
    @carts_router = SkyStone::CartsRouter.new(self)
    @carts_terminal = SkyStone::CartsTerminal.new(self)
  end

  private

  def cmd(player, arguments)
    if arguments.length > 0
      subcommand = arguments.shift

      case subcommand.to_sym
      when :eval
        eval arguments.join(" ")
      when :inspect
        player.msg "#{player.target_block.inspect}/#{player.target_block.get_data}"
      when :route
        @carts_router.cmd(player, arguments)
      when :storage
        @storage_cart_system.cmd(player, arguments)
      end
    end
  end

  def force_reload!
    load 'SkyStone/plugin.rb'
    load 'SkyStone/storage_cart_system.rb'
    load 'SkyStone/carts_router.rb'
    load 'SkyStone/carts_terminal.rb'
    load 'SkyStone/system_block.rb'
    load 'SkyStone/block.rb'
    load 'SkyStone/transceiver.rb'
    load 'SkyStone/orientation.rb'
    load 'SkyStone/vehicle_move_event.rb'
  end
end