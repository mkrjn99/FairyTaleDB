We can transform comments column in this way for each Block Type:

1. INI: Comments column should contain empty string after transformation.
2. DIS: The original statement will be: "'X' and 'Y' agreed that for the next 'M' INR ChefBytes team credits to 'Y', ChefBytes will sell 'N' INR worth of food. 'Z' agreed that he will be responsible for the 'N' INR worth of sold food henceforth" where single capital letters within apostrophe will be variables. Let's make the statement: "X->Y Discount: (M-N) Responsibility: Z".
3. MEX: Keep as is.
4. NME: Keep as is.
5. AUT: This statement will be like "X authorised Y for Z", let's make it "X->Y Z".
