from alphabet import Alphabet


class EngAlphabet(Alphabet):
    def __init__(self, lang, letters, numOfLetters):
        EngAlphabet.__letters_num = numOfLetters
        super().__init__(lang=lang, letters=letters)

    def is_en_letter(self, letter):
        return letter.upper() in self.letters

    def letters_num(self):
        return EngAlphabet.__letters_num

    @staticmethod
    def example():
        return "The quick brown fox jumps over the lazy dog."
    

engAlphabet = EngAlphabet("En", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 26)
engAlphabet.print()
print(f"Number of letters: {engAlphabet.letters_num()}")
engAlphabet.is_en_letter("F")
engAlphabet.is_en_letter("Щ")
print(EngAlphabet.example())