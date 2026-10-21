enum EstadoOvo {
  cru('Ovo Cru 🥚'),
  gemaMole('Gema Mole 🍳'),
  noPonto('No Ponto 🥚'),
  gemaDura('Gema Dura 🥚'),
  cancelado('Preparo Cancelado! 🔥❌');

  const EstadoOvo(this.descricao);

  final String descricao;
}
