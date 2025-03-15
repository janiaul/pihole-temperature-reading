#!/bin/bash

# Adds a temperature reading line to the Pi-hole admin interface via the sidebar.lp file

# File path
SIDEBAR_FILE="/var/www/html/admin/scripts/lua/sidebar.lp"

# Check if file exists
if [ ! -f "$SIDEBAR_FILE" ]; then
    echo "Error: $SIDEBAR_FILE does not exist."
    exit 1
fi

# Check if temperature display is already added
if grep -q "id=\"temperature\"" "$SIDEBAR_FILE"; then
    echo "Temperature display is already present in the Pi-hole admin interface."
    exit 0
fi

# Make a backup of the original file
cp "$SIDEBAR_FILE" "${SIDEBAR_FILE}.bak"
echo "Backup created at ${SIDEBAR_FILE}.bak"

# Apply the change using sed
sed -i '/<span id="memory"><\/span>/s/<\/span>/<\/span><br\/>\n                    <span id="temperature">\&nbsp;\&nbsp;<i class="fa-solid fa-temperature-three-quarters text-green-light"><\/i>\&nbsp;\&nbsp; Temp: <%= string.format("%.1f°C", tonumber(io.open("\/sys\/class\/thermal\/thermal_zone0\/temp"):read("*a")) \/ 1000) %><\/span>/' "$SIDEBAR_FILE"

# Check if the change was applied successfully
if grep -q "id=\"temperature\"" "$SIDEBAR_FILE"; then
    echo "Temperature display successfully added to Pi-hole admin interface."
else
    echo "Error: Failed to add temperature display."
    echo "Restoring from backup..."
    mv "${SIDEBAR_FILE}.bak" "$SIDEBAR_FILE"
    exit 1
fi

echo "Complete! You may need to refresh your Pi-hole admin page to see the changes."
exit 0