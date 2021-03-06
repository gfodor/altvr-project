// Generated by CoffeeScript 1.5.0
(function() {
  var Board, t;

  t = THREE;

  Board = (function() {

    function Board(id, width, height, position, yaw, pitch) {
      var aspectRatio;
      this.id = id;
      this.width = width;
      this.height = height;
      this.buildBoardMesh(position, yaw, pitch);
      this.mesh.__board = this;
      this.canvas = document.createElement("canvas");
      aspectRatio = this.height * 1.0 / (this.width * 1.0);
      this.canvas.width = 1024;
      this.canvas.height = 1024.0 * aspectRatio;
      true;
    }

    Board.prototype.buildBoardMesh = function(position, yaw, pitch) {
      var axis;
      this.geometry = new t.PlaneGeometry(this.width, this.height);
      this.material = new t.MeshLambertMaterial({
        color: "#FFFFFF"
      });
      this.mesh = new t.Mesh(this.geometry, this.material);
      axis = new t.Vector3(Math.cos(yaw), 0, -Math.sin(yaw));
      this.mesh.rotateOnAxis(axis, pitch);
      this.mesh.rotateOnAxis(new t.Vector3(0, 1, 0), yaw);
      return this.mesh.position.copy(position);
    };

    Board.prototype.addToScene = function(scene) {
      scene.add(this.mesh);
      this.createPointLight(scene);
      return this.createBoardFrame(scene);
    };

    Board.prototype.createPointLight = function(scene) {
      this.light = new t.PointLight(0xFFFFFF, Math.floor(this.width * this.height / 10), 10);
      this.light.position.copy(this.mesh.position);
      this.nudgeFromBoard(this.light, 3);
      return scene.add(this.light);
    };

    Board.prototype.createBoardFrame = function(scene) {
      var geometry, material;
      geometry = new t.BoxGeometry(this.width + 0.2, this.height + 0.2, 0.2);
      material = new t.MeshLambertMaterial({
        map: t.ImageUtils.loadTexture("/images/wood2.jpg")
      });
      this.frame = new t.Mesh(geometry, material);
      this.frame.position.copy(this.mesh.position);
      this.frame.rotation.copy(this.mesh.rotation);
      this.nudgeFromBoard(this.frame, -0.15);
      return scene.add(this.frame);
    };

    Board.prototype.nudgeFromBoard = function(target, amount) {
      var norm, normalMatrix;
      norm = new t.Vector3();
      norm.copy(this.geometry.faces[0].normal);
      this.mesh.updateMatrixWorld();
      normalMatrix = new t.Matrix3();
      normalMatrix.getNormalMatrix(this.mesh.matrixWorld);
      norm.applyMatrix3(normalMatrix);
      norm.multiplyScalar(amount);
      return target.position.add(norm);
    };

    Board.prototype.drawOn = function(f) {
      var ctx;
      ctx = this.canvas.getContext('2d');
      return f(ctx, this.canvas.width, this.canvas.height);
    };

    Board.prototype.refresh = function() {
      var ctx, image, texture;
      ctx = this.canvas.getContext('2d');
      image = new Image();
      ctx.save();
      texture = new t.Texture(ctx.getImageData(0, 0, this.canvas.width, this.canvas.height));
      texture.needsUpdate = true;
      return this.material.setValues({
        map: texture
      });
    };

    return Board;

  })();

  window.Board = Board;

}).call(this);
