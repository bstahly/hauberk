import 'package:piecemeal/piecemeal.dart';

import '../action/action.dart';
import '../actor.dart';
import '../attack.dart';

/// A thing that can be picked up.
class Item extends Thing implements Comparable {
  final ItemType type;

  final Affix prefix;
  final Affix suffix;

  Item(this.type, [this.prefix, this.suffix]) : super(Vec.zero);

  get appearance => type.appearance;

  bool get isRanged => type.attack is RangedAttack;

  bool get canEquip => equipSlot != null;
  String get equipSlot => type.equipSlot;

  /// Whether the item can be used or not.
  bool get canUse => type.use != null;
  Action use() => type.use();

  /// Whether the item can be thrown or not.
  bool get canToss => type.tossAttack != null;

  /// Gets the melee [Attack] for the item, taking into account any [Affixes]s
  // it has.
  Attack get attack {
    if (type.attack == null) return null;

    var attack = type.attack;
    if (prefix != null && prefix.attack != null) {
      attack = attack.combine(prefix.attack);
    }

    if (suffix != null && suffix.attack != null) {
      attack = attack.combine(suffix.attack);
    }

    return attack;
  }

  /// The amount of protected provided by the item when equipped.
  int get armor => type.armor;

  String get nounText {
    final name = new StringBuffer();
    name.write('a ');

    if (prefix != null) {
      name.write(prefix.name);
      name.write(' ');
    }

    name.write(type.name);

    if (suffix != null) {
      name.write(' ');
      name.write(suffix.name);
    }

    return name.toString();
  }

  // TODO: Take affixes into account.
  int get price => type.price;

  bool get isTreasure => type.isTreasure;

  int compareTo(Item other) {
    // TODO: Take into account affixes.
    return type.sortIndex.compareTo(other.type.sortIndex);
  }

  /// Creates a new [Item] with the same type and affixes as this one.
  Item clone() => new Item(type, prefix, suffix);
}

typedef Action ItemUse();

/// A kind of [Item]. Each item will have a type that describes the item.
class ItemType {
  final String name;
  final appearance;

  /// The item's level.
  ///
  /// Higher level items are found later in the game. Some items may not have
  /// a level.
  final int level;

  final int sortIndex;

  /// The name of the [Equipment] slot that [Item]s can be placed in. If `null`
  /// then this Item cannot be equipped.
  final String equipSlot;

  final ItemUse use;

  /// The item's [Attack] or `null` if the item is not an equippable weapon.
  final Attack attack;

  /// The item's [RangedAttack] when thrown or `null` if the item can't be
  /// thrown.
  final RangedAttack tossAttack;

  /// The percent chance of the item breaking when thrown. `null` if the item
  /// can't be thrown.
  final int breakage;

  final int armor;

  /// The path to this item type in the hierarchical organization of items.
  ///
  /// May be empty for uncategorized items.
  final List<String> categories;

  /// A more precise categorization than [equipSlot]. For example, "dagger",
  /// or "cloak". May be `null`.
  String get category {
    if (categories.isEmpty) return null;
    return categories.last;
  }

  /// How much gold this item is worth.
  final int price;

  /// True if this item is "treasure".
  ///
  /// That means it just has a gold value. As soon as the hero steps on it, it
  /// increases the hero's gold and disappears.
  bool isTreasure;

  ItemType(this.name, this.appearance, this.level, this.sortIndex,
      this.categories, this.equipSlot, this.use, this.attack, this.tossAttack,
      this.breakage, this.armor, this.price, {treasure: false})
      : isTreasure = treasure;

  String toString() => name;
}

/// A modifier that can be applied to an [Item] to change its capabilities.
/// For example, in a "Dagger of Wounding", the "of Wounding" part is an affix.
class Affix {
  final String name;

  final Attack attack;

  Affix(this.name, this.attack);
}

typedef void AddItem(Item item);

abstract class Drop {
  void spawnDrop(AddItem addItem);
}
