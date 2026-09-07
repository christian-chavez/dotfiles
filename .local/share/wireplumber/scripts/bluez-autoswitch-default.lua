-- bluez-autoswitch-default.lua
--
-- Make a Bluetooth output the default sink as soon as it connects.
--
-- On disconnect there is nothing to do: WirePlumber's stock default-node
-- hooks automatically fall back to the highest-priority sink that is still
-- present (the laptop's internal speakers).
--
-- Mechanism: this mirrors exactly what "selecting the device in pavucontrol"
-- does -- it writes the node name into the `default.configured.audio.sink`
-- key of the `default` metadata. WirePlumber's find-selected-default-node
-- hook then gives that node top priority and switches to it.
--
-- Enabled by ~/.config/wireplumber/wireplumber.conf.d/51-bluez-autoswitch-default.conf

Log.info ("bluez-autoswitch: loaded, watching for Bluetooth sinks")

metadata_om = ObjectManager {
  Interest {
    type = "metadata",
    Constraint { "metadata.name", "=", "default" },
  }
}

bt_sink_om = ObjectManager {
  Interest {
    type = "node",
    Constraint { "media.class", "matches", "Audio/Sink", type = "pw-global" },
    Constraint { "node.name", "matches", "bluez_output.*", type = "pw-global" },
  }
}

bt_sink_om:connect ("object-added", function (_, node)
  local name = node.properties ["node.name"]
  if not name then
    return
  end

  local metadata = metadata_om:lookup {
    Constraint { "metadata.name", "=", "default" }
  }
  if not metadata then
    return
  end

  Log.info ("bluez-autoswitch: Bluetooth sink connected, setting as default: " .. name)
  metadata:set (0, "default.configured.audio.sink", "Spa:String:JSON",
      Json.Object { name = name }:to_string ())
end)

metadata_om:activate ()
bt_sink_om:activate ()
