// Generated by CoffeeScript 1.4.0
(function() {
  var Board, t;

  t = THREE;

  Board = (function() {

    function Board(scene, width, height, position, yaw, pitch) {
      var aspectRatio, norm, normalMatrix;
      this.geometry = new t.PlaneGeometry(width, height);
      this.material = new t.MeshLambertMaterial({
        color: "#FFFFFF"
      });
      this.mesh = new t.Mesh(this.geometry, this.material);
      this.mesh.position.copy(position);
      this.mesh.rotateOnAxis(new t.Vector3(0, 1, 0), yaw);
      this.mesh.rotateOnAxis(new t.Vector3(1, 0, 0), pitch);
      this.canvas = document.createElement("canvas");
      aspectRatio = height * 1.0 / (width * 1.0);
      this.canvas.width = 1024;
      this.canvas.height = 1024.0 * aspectRatio;
      this.light = new t.PointLight(0xFFFFFF, Math.floor(width * height / 10), 10);
      this.light.position.copy(position);
      scene.add(this.mesh);
      norm = new t.Vector3();
      norm.copy(this.geometry.faces[0].normal);
      this.mesh.updateMatrixWorld();
      normalMatrix = new t.Matrix3();
      normalMatrix.getNormalMatrix(this.mesh.matrixWorld);
      norm.applyMatrix3(normalMatrix);
      norm.multiplyScalar(3);
      this.light.position.add(norm);
      scene.add(this.light);
    }

    Board.prototype.draw = function(f) {
      var ctx, image, texture;
      ctx = this.canvas.getContext('2d');
      f(ctx, this.canvas.width, this.canvas.height);
      image = new Image();
      ctx.save();
      image.src = this.canvas.toDataURL();
      texture = new t.Texture(image);
      texture.needsUpdate = true;
      return this.material.setValues({
        map: texture
      });
    };

    return Board;

  })();

  window.Board = Board;

}).call(this);
