function addUrlInput(id) {
    var input = document.createElement('input');
    input.type = 'text';
    input.name = 'url';
    input.className = 'text_field';
    var el = document.getElementById(id);
    el.appendChild(input);
    el.appendChild(document.createElement('br'));
    input.focus();
}

function showGMap(url, id) {
    if (GBrowserIsCompatible()) {
        var map = new GMap2(document.getElementById(id));
        map.addControl(new GSmallMapControl());
        //map.addControl(new GMapTypeControl());

        var lng = {min: 0, max: 0};
        var lat = {min: 0, max: 0};

        $.get(url, function(data) {
            var coodinatesList = data.getElementsByTagName('coordinates');
            for (var i = 0; i < coodinatesList.length; i++) {
                var str = coodinatesList[i].firstChild.nodeValue;
                var coordinates = str.split(',');
                var _lng = new Number(coordinates[0]);
                var _lat = new Number(coordinates[1]);
                if (lng.min == 0 || lng.min > _lng) { lng.min = _lng }
                if (lat.min == 0 || lat.min > _lat) { lat.min = _lat }
                if (lng.max == 0 || lng.max < _lng) { lng.max = _lng }
                if (lat.max == 0 || lat.max < _lat) { lat.max = _lat }
            }

            var bounds = new GLatLngBounds(new GLatLng(lat.max, lng.min), new GLatLng(lat.min, lng.max));
            var center = bounds.getCenter();
            var zoom = map.getBoundsZoomLevel(bounds);
            map.setCenter(new GLatLng(center.lat(), center.lng()), zoom);
            map.addOverlay(new GGeoXml(url));
            //map.enableScrollWheelZoom();
        });
    }
}
