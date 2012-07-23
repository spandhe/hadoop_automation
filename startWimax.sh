modprobe i2400m_usb
wimaxd -i wmx0 -b
sleep 2
wimaxcu ron
sleep 5
wimaxcu connect network 51
sleep 5
dhclient wmx0