# -*- coding: utf-8 -*-
module TDiary
	module RequestExtension
		def mobile_agent?
			self.user_agent =~ %r[(DoCoMo|J-PHONE|Vodafone|MOT-|UP\.Browser|DDIPOCKET|ASTEL|PDXGW|Palmscape|Xiino|sharp pda browser|Windows CE|L-mode|WILLCOM|SoftBank|Semulator|Vemulator|J-EMULATOR|emobile|mixi-mobile-converter)]i
		end

		def smartphone?
			self.user_agent =~ /iPhone|iPod|Opera Mini|Android.*Mobile|NetFront|PSP/
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
