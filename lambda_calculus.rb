class Parsed_Tree
    attr_accessor :is_lambda, :left, :right, :val, :id

    def initialize
        @is_lambda = false
        @left = nil
        @right = nil
        @val = "nil"
        @id
    end

    def printtree

        if self == nil
            return
        end

        if @is_lambda == true
            print "lambda "
        end

        puts @val

        if @left != nil
            @left.printtree
        end

        if @right != nil
            @right.printtree
        end
    end

    def search_and_replace what,with 
        if @left != nil
            if @left.val == what
                self.left = with
            elsif @left.val == "nil"
                self.left.search_and_replace(what,with)
            end
        end

        if @right != nil
            if @right.val == what
                self.right = with
            elsif @right.val == "nil"
                self.right.search_and_replace(what,with)
            end
        end

    end

    def substitution_of_free_occurence this, with_this

        if @left != nil
            if @left.val == this
                @left = with_this
            else
                check_free = @left.give_free_var
                if check_free.include? this
                    @left = @left.substitution_of_free_occurence this, with_this
                end
            end
        end

        if @right != nil
            if @right.val == this
                @right = with_this
            else
                check_free = @right.give_free_var
                if check_free.include? this
                    @right = @right.substitution_of_free_occurence this, with_this
                end
            end
        end

        return self

    end

    def give_free_var

        sl = Array.new
        sr = Array.new

        if self == nil
            return []
        end

        if @val != "nil"
            sl = [@val]
            return sl 
        end

        if self.is_lambda 
            sr = @right.give_free_var
            sr.delete(@left.val)
            return sr
        end

        if @left != nil
            sl = @left.give_free_var
        else
            sl = []
        end
        if @right != nil
            sr = @right.give_free_var
        else
            sr = []
        end
        
        return sl|sr
    end

    def give_bound_var

        s_all = Array.new
        s_free = Array.new
        s_bound = Array.new

        s_all = self.give_all_var
        s_free = self.give_free_var



        s_bound = s_all - s_free

        return s_bound

    end

    def give_all_var

        sl = Array.new
        sr = Array.new

        if self == nil
            return []
        end

        if @val != "nil"
            sl = [@val]
            return sl 
        end

        if @left != nil
            sl = @left.give_all_var
        else
            sl = []
        end
        if @right != nil
            sr = @right.give_all_var
        else
            sr = []
        end
        
        return sl|sr

    end

    def beta_reduce
        if @val != "nil"
            return self
        end

        if !@is_lambda && @val== "nil"
            return self.apply
        end

        if @is_lambda == true
            @right = @right.beta_reduce
        end

        return self

    end

    def apply 
        if @left != nil
            treel = @left.beta_reduce
        else
            treel = nil
        end
        if @right != nil
            treer = @right.beta_reduce
        else
            treer = nil
        end
        if treel != nil && treer != nil && treel.is_lambda 
            bounde1 = Array.new
            freee2 = Array.new
            possib = Array.new
            bounde1 = treel.right.give_bound_var
            freee2 = treer.give_free_var
            possib = bounde1 & freee2

            if possib.length == 0
                if treel.right.val == treel.left.val
                    treel.right = treer
                else
                    treel.right.search_and_replace(treel.left.val, treer)
                end
            end
            return treel.right
        end
        @left = treel
        @right = treer
        return self
    end

    def express 

        if self == nil
            return
        end
        
        if self.val == "nil"
            print "("
        else
            print self.val
        end
        if self.is_lambda == true
            print "\\"
        end

        if @left != nil
            @left.express
        end

        if self.is_lambda == true
            print "."
        end

        if @right != nil
            @right.express
        end

        if self.val == "nil"
            print ")"
        end

    end

end

def islower? char
    char >= 'a' && char <= 'z'
end

class Lambda_expression

    attr_accessor :tree

    def initialize expression
        @expression = expression
        @tree = Parsed_Tree.new
        @i = 0
        @is_valid = true
        self.buildtree
    end

    def parseE 

        if @i >= @expression.length
            return nil
        end

        curri = @i

        root = Parsed_Tree.new()

        if @expression[@i] == '('
            @i = @i+1
            key = 1
            root.left = parseE 
            if @expression[@i] == ')' && key == 1
                @i = @i+1
                key = 0
            elsif key == 1
                @is_valid = false
            end

            if @expression[@i] == '('
                @i = @i+1
                key = 1
            end
            root.right = parseE
            if @expression[@i] == ')' && key == 1
                @i = @i+1
                key = 0
            elsif key == 1
                @is_valid = false
            end
        elsif @expression[@i] == '\\'
            @i = @i+1
            root.is_lambda = true
            node = Parsed_Tree.new()
            node.val = @expression[@i]
            root.left = node
            @i = @i+1
            if @expression[@i] == '.'
                @i = @i+1
            else
                @is_valid = false
            end

            if @expression[@i] == '('
                @i = @i+1
                key = 1
            end
            root.right = parseE
            if @expression[@i] == ')' && key == 1
                @i = @i+1
                key = 0
            elsif key == 1
                @is_valid = false
            end
        elsif islower? @expression[@i]
            nodel = Parsed_Tree.new()
            noder = Parsed_Tree.new()
            nodel.val = @expression[@i]
            @i = @i+1
            if (@i<@expression.length) && (islower? @expression[@i])
                noder.val = @expression[@i]
                @i = @i+1
                root.left = nodel
                root.right = noder
            elsif (@expression[@i] == '(')
                @i = @i+1
                noder = parseE
                if (@expression[@i] == ')')
                    @i = @i+1
                else
                    @is_valid = false
                end
                root.left = nodel
                root.right = noder
            else
                root = nodel
            end
        else
            @is_valid = false
        end

        return root

    end

    def buildtree
        @tree = parseE 
    end

    def is_valid?
        if @i != @expression.length
            @is_valid = false
        end
        return @is_valid
    end

    def beta_reduce
        if @is_valid
            @tree = @tree.beta_reduce
            puts "\nBeta Reduced:"
            @tree.express
        else
            puts "Expression not Valid!!"
        end
    end

    def give_free_var
        @tree.give_free_var
    end

    def substitute this, with_this
        w = Lambda_expression.new with_this
        check_free = @tree.give_free_var
        if check_free.include? this
            @tree.substitution_of_free_occurence this, w.tree
        end
        printf "Substituting free occurence of %s with %s in %s\n",this,with_this,@expression
        @tree.express
    end

end

exp1 = "(\\b.(\\c.b))c"

exp2 = "((\\y.y)(\\x.(\\z.(zy))))w"

exp3 = "((\\x.(\\y.((xy)z)))(ab))c"

exp4 = "(\\b.(m(\\z.y)))"

exp5 = "(\\x.(xx))(\\x.(xx))"

check = Lambda_expression.new(exp2)

check.tree.express

print "\n"

puts exp2

puts check.is_valid?

print check.give_free_var

print "\n"

check.substitute 'y', 'a'

# check.beta_reduce

print "\n"