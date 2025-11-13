import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UsersService } from '../../users/users.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private usersService: UsersService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'your-secret-key',
    });
  }

  async validate(payload: any) {
    console.log('🔐 [JWT STRATEGY] validate() called');
    console.log('📋 [JWT STRATEGY] JWT payload received:', payload);
    console.log('🆔 [JWT STRATEGY] Looking for user ID:', payload.sub);
    
    const user = await this.usersService.findOne(payload.sub);
    console.log('👤 [JWT STRATEGY] User found:', user ? `${user.email} (ID: ${user.id})` : 'null');
    
    const { password, ...result } = user;
    console.log('✅ [JWT STRATEGY] Returning user:', result);
    return result;
  }
}