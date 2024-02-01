**BUSER DANIELE 894514**

---

INTRODUZIONE

Ai tempi di Simula e del primo Smalltalk, molto molto tempo prima di
Python, Ruby, Perl e SLDJ, i programmatori Lisp giá producevano una
pletora di linguaggi object oriented. Il vostro progetto consiste
nella costruzione di un’estensione “object oriented” di Common Lisp,
chiamata OOΛ, e di un’estensione “object oriented” di Prolog, chiamata
OOΠ.

---

**OOΠ**

Le principali primitive di OOΠ sono quattro: def_class, make, field,
fieldx.

---

**def_class**

La primitiva `def_class` accetta due argomenti: il nome della classe e
una lista di parti, che possono essere campi o metodi. I campi sono
coppie di nome e valore mentre i metodi sono liste di nomi di
parametri e corpo del metodo.

Ad esempio, la seguente istruzione definisce una classe `student` con
due campi, `name` e `university`, e un metodo `talk()`:

```
def_class(student, [person],
		[field(name, ’Eva Lu Ator’),
		 field(university, ’Berkeley’),
		 method(talk, [],
					(write(My name is ’),
					 field(this, name, N),
					 writeln(N),
					 write(’My age is ’)
					 field(this, age, A),
					 writeln(A)))]).
```

---

**make**

La primitiva `make` accetta tre argomenti: il nome dell'istanza, il
nome della classe e una lista di campi con i relativi valori. Viene
creata un'istanza con i campi specificati.

Ad esempio, la seguente istruzione crea un'istanza `s1` della classe
`student` con i campi `name` e `age`:

```
make(s1, student, [name = ’Eduardo De Filippo’, age = 108]).
```

---

**field**

La primitiva `field` accetta tre argomenti: il nome dell'istanza, il
nome del campo e la variabile che conterrà il valore del campo. Estrae
il valore del campo specificato dall'istanza.

Ad esempio, la seguente istruzione estrae il valore del campo `age`
dell'istanza `s1`:

```
field(s1, age, A).
```

---

**fieldx**

La primitiva `fieldx` accetta tre argomenti: il nome dell'istanza, una
lista di nomi di campi e la variabile che conterrà il valore
dell'ultimo campo nella lista. Estrae il valore del campo specificato
dall'istanza.

Ad esempio, deve valere la seguente equivalenza:

```
field(I1, s1, V1),
field(V1, s2, V2),
field(V2, s3, R),
fieldx(I1, [s1, s2, s3], R).
```

---

ALTRE FUNZIONI UTILIZZATE PER QUESTO PROGETTO

- `field_structure` : definisce la struttura di un campo.
- `method_strcture` : definisce la struttura di un metodo.

- `is-class` : prende in input il nome di una classe e stabilisce se
  esiste una classe definita con quel nome.
- `is-instance` : prende in input un valore e il nome di una classe.
- `inst` : prende in input il nome di un'istanza e ritorna l'istanza
  che é stata creata da make.
- `check_part` : prende in input un campo o un metodo e chiama il
  controllo sulla struttura dello stesso.
- `check_field_structure` : prende in input un campo e controlla che
  la struttura sia correttamente definita.
- `field_value_type_compatible` : prende in input valore e tipo di un
  campo e controlla la compatibilitá.
- `all_superclasses` : prende in input il nome di una classe e una
  lista che viene restituita con tutte le superclassi dirette e
  indirette della classe.
- `field_in_class_or_superclass` : prende in input il nome della
  classe e un campo e controlla se questo é presente nella classe o
  nelle sue superclassi.
- `is_superclass` : prende in input il nome di una classe e una
  superclasse e stabilisce se la superclasse é superclasse della
  classe.
- `subtype` : stabilisce le gerarchie tra tipi.
- `subtypep` : prende in input due tipi e controlla se il primo é
  sottotipo del secondo.
- `check_field_type_width_in_superclasses` : prende in input una lista
  di parents e un campo e chiama il controllo sull'ampiezza.
- `check_field_type_width` : prende in input un campo e il nome di una
  classe e controlla che il tipo del campo non sia piú ampio di quello
  nelle superclassi.
- `replace_this` : prende in input 4 termini e sostituisce un vecchio
  termine con uno nuovo, viene usato per sostituire il "this".
- `process_method` : prende in input il nome di un metodo il nome di
  una classe e una lista di argomenti e asserisce il metodo nella base
  di conoscenza.
- `call_method` : prende in input il nome di un metodo il nome di
  un'istanza e una lista di argomenti si occupa della vera e propria
  chiamata diretta al metodo.
