void main() {
  Animal().move();
  Fish().move();
  Bird().move();
}

class Animal {
  void move() {
    print('Changed position');
  }
}

class Fish extends Animal {
  @override
  void move() {
    super // super <=> "the parent class instance (Animal)"
        .move(); // We do what our parent class does, then the unique code comes into place : it's inheritance !
    print("by Swimming");
  }
}

class Bird extends Animal {
  @override
  void move() {
    super
        .move(); // We do what our parent class does, then the unique code comes into place :
    print("by Flying");
  }
}

//  What about Ducks ? (they're animals who can both fly and swim ?) :
// We can't just double extend : duck extends animal extends bird exte... NO !

mixin CanSwim {
  void swim() {
    print('Changed position by swimming');
  }
}

mixin CanFly {
  void swim() {
    print('Changed position by flying');
  }
}

class Duck extends Animal with CanFly, CanSwim {
  //  Duck now has all methods : move, fly and swim
}

class Human with CanSwim {}
class Plane with CanFly{}
//  => You can use mixins independently of the parent class

// The changes made on the mixins are dynamic : if you change a mixin, it applies 
//  to everywhere it was used with.