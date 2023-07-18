mapboxgl.accessToken = 'pk.eyJ1IjoiY29sdmVnIiwiYSI6ImNsZmhldXJxZDBpOWEzenF3cGtoNmYxYXEifQ.h0jhKpVYo6t_8uFcoS_uxg';

var map = new mapboxgl.Map({
    container: 'mapa',
    style: 'mapbox://styles/mapbox/streets-v11',
    center: [-122.4194, 37.7749],
    zoom: 12
});