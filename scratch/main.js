// Generated by CoffeeScript 1.4.0
(function() {
  var camera, clock, controls, cube, floor, geometry, light, material, render, renderer, scene, t;

  t = THREE;

  $("body").click(function() {
    var element;
    element = $("body")[0];
    element.requestPointerLock = element.requestPointerLock || element.mozRequestPointerLock || element.webkitRequestPointerLock;
    return element.requestPointerLock();
  });

  scene = new t.Scene();

  camera = new t.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);

  renderer = new t.WebGLRenderer();

  renderer.setSize(window.innerWidth, window.innerHeight);

  document.body.appendChild(renderer.domElement);

  light = new t.DirectionalLight(0xFFFFFF, 3);

  light.position.set(0.0, 20, 4);

  light.rotateOnAxis(new t.Vector3(1, 0, 0), -Math.PI * 0.15);

  scene.add(light);

  light = new t.AmbientLight(0x202020);

  scene.add(light);

  geometry = new t.BoxGeometry(10, 8, 0.1);

  material = new t.MeshLambertMaterial({
    color: 0xffffff
  });

  cube = new t.Mesh(geometry, material);

  cube.position.y = 12;

  cube.position.z = -10;

  scene.add(cube);

  material = new t.MeshLambertMaterial({
    map: t.ImageUtils.loadTexture("doge.jpeg")
  });

  floor = new t.Mesh(new t.BoxGeometry(100, 0.1, 100), material);

  floor.position.x = 0;

  floor.position.y = 0;

  floor.position.z = 0;

  scene.add(floor);

  clock = new t.Clock();

  controls = new t.PointerLockControls(camera);

  controls.enabled = true;

  scene.add(controls.getObject());

  render = function() {
    var delta;
    delta = clock.getDelta();
    controls.update(delta);
    camera.updateMatrix();
    camera.updateMatrixWorld();
    requestAnimationFrame(render);
    return renderer.render(scene, camera);
  };

  render();

}).call(this);
