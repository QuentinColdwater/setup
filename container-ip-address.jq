# {container-id: container-info}
.[0].Containers |

# Get a list of the container-info objects
values |

# Narrow list to just container with given name
map(select(.Name == $container_name)) |

# Verify there is exactly one such container.  The 'else .' 
# notation feeds the data unchanged through to next stage
if length == 0 then error("No such container")   else . end |
if length != 1 then error("Should never happen") else . end |

# IP address for container
.[0].IPv4Address |

# Convert from CIDR notation to raw IP address
sub("/.*"; "")