# the point of this demo is purely for convenience where instead of typing make
# my_very_long_file_name, you can type make first
.PHONY: all first second third

# save long file names that you want to alias into variables
one   := file_one_one_one_one_one.txt
two   := file_two_two_two_two_two.txt
three := file_three_three_three_three_three.txt

all: $(three)

# the important part is that targets and dependencies depend on the real
# files (even if they are variables) and not on their aliases, e.g., first is
# the alias and $(one) is the variable to the file
first: $(one)
$(one):
	touch $@

second: $(two)
$(two): $(one)
	touch $@

third: $(three)
$(three): $(two)
	touch $@

clean:
	rm -rf file_one_one_one_one_one.txt file_two_two_two_two_two.txt file_three_three_three_three_three.txt
