Geocoder.configure(
  ip_lookup: :freegeoip,
  timeout: 8
) if defined?(Geocoder)